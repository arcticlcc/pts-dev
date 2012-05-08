<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for persons(contacts).
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Person implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = new ControllerCollection();
        $table = 'person';
        $related = array(
            'addresses'=>array('name' =>'address'),
            'eaddresses'=>array('name' => 'eaddress'),
            'phones'=>array('name' => 'phone'),
        );

        $controllers->get('person/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();

            try {
                $object = $app['idiorm']->getTable($table)
                    ->join('contact', array('person.contactid', '=', 'contact.contactid'))
                    ->where('person.contactid', $id)
                    ->find_one();

                //get primary mail/physical addresses, assumes priority is set to 1
                $addresses = $app['idiorm']->getRelated(true, 'address', 'contactid', $id,
                    array('priority'=>1, 'addresstypeid' => array(1,2)));

                //get primary office/mobile/fax phone#s, assumes priority is set to 1
                $phones = $app['idiorm']->getRelated(true, 'phone', 'contactid', $id,
                    array('priority'=>1, 'phonetypeid' => array(1,2,3)));

                //get primary website and e-mail, assumes priority is set to 1
                $eaddresses = $app['idiorm']->getRelated(true, 'eaddress', 'contactid', $id,
                    array('priority'=>1, 'eaddresstypeid' => array(1,2)));

                if($object) {
                    $result = $object->as_array();
                    $result['addresses'] = $addresses;
                    $result['phones'] = $phones;
                    $result['eaddresses'] = $eaddresses;
                    $app['json']->setData($result);
                }else {
                    $message = "No record found in table '$table' with id of $id.";
                    $success = false;
                    $code = 404;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll($result,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });

        $controllers->get('person/{id}/group', function (Application $app, Request $request, $id) {
            $table = 'membergrouplist'; //need to use membergrouplist view

            $app['getRelated']($request, $table, 'contactid', $id);

            return $app['json']->getResponse();
        });

        $controllers->put('person/{pid}/group/{id}', function (Application $app, Request $request, $pid, $id) {
            $table = 'contactcontactgroup';
            $result = array();

            $result = $app['saveTable']($request, $table, $id, 'membergrouplist');
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->post('person/{pid}/group', function (Application $app, Request $request) {
            $table = 'contactcontactgroup'; //need to use membergrouplist view
            $result = array();

            $result = $app['saveTable']($request, $table, null, 'membergrouplist');
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->put('person/{id}', function (Application $app, Request $request, $id) use ($related) {
            $result = array();

            try {
                $values = json_decode($request->getContent());
                $app['mergeRelated'](&$related, &$values);
                $sql = "
                    WITH contact as (UPDATE contact
                        SET comment=:comment, dunsnumber=:dunsnumber, contacttypeid=:contacttypeid, inactive=:inactive
                        WHERE contactid = :contactid
                        RETURNING *
                    ), person as (UPDATE person
                        SET firstname=:firstname, lastname=:lastname, middlename=:middlename, suffix=:suffix, positionid =:positionid
                        WHERE contactid = :contactid
                    RETURNING *
                    )
                    SELECT * FROM contact,person;
                ";
                //TODO: remove priority when not needed
                $result = $app['saveRelatedTransaction']($values, $related, $sql, 'contactid', $id, array('priority'=>1));
                //need to handle transaction manually to account for errors WRT related data
                /*$app['db']->transactional(function($conn) use ($app, $values, $related, $id, &$result) {
                    $sql = "
                        WITH contact as (UPDATE contact
                            SET comment=:comment, dunsnumber=:dunsnumber, contacttypeid=:contacttypeid
                            WHERE contactid = :contactid
                            RETURNING *
                        ), person as (UPDATE person
                            SET firstname=:firstname, lastname=:lastname, middlename=:middlename, suffix=:suffix, positionid =:positionid
                            WHERE contactid = :contactid
	                    RETURNING *
                        )
                        SELECT * FROM contact,person;
                    ";
                    $stmt = $conn->prepare($sql);

                    foreach ($values as $k => $v)  {
                        $stmt->bindValue($k, $v);
                    }
                    $stmt->bindValue('contactid', $id);
                    $stmt->execute();
                    $result = $stmt->fetch(\PDO::FETCH_ASSOC);

                    //save related data
                    foreach ($related as $rClass => $rTable)  {
                        //we're assuming the primarykey is {tablename}id
                        $pk = $rTable['name'].'id';
                        if(isset($rTable['values'])) {
                            foreach ($rTable['values'] as $k => $v)  {
                                //make sure the foreignkey is set
                                $v->contactid = $id;
                                //var_dump($v);exit;
                                //save the related data and add returned data to the result array
                                $app['saveRelated']($v, $rTable['name'], $v->$pk);
                            }
                        }
                        //we return all of the related records, ExtJS associations require this
                        //TODO: remove priority when not needed
                        $result[$rClass] = $app['idiorm']->getRelated(true, $rTable['name'], 'contactid',$id ,
                            array('priority'=>1));

                    }
                });*/

                $app['json']->setData($result);
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll($result,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });

        $controllers->post('person', function (Application $app, Request $request) use ($related) {

            $result = array();

            try {
                $values = json_decode($request->getContent());
                $app['mergeRelated'](&$related, &$values);
                $sql = "
                    WITH contact as (
                        INSERT INTO contact(
                                contactid, comment, dunsnumber, contacttypeid,inactive)
                            VALUES (DEFAULT, :comment, :dunsnumber, :contacttypeid,:inactive)
                            RETURNING *
                    ), person as (INSERT INTO person(
                                contactid, firstname, lastname, middlename, suffix, positionid)
                        SELECT contactid , :firstname, :lastname, :middlename, :suffix, :positionid
                        FROM contact
                        RETURNING *
                    )
                    SELECT * FROM contact,person;
                ";
                //TODO: remove priority when not needed
                $result = $app['saveRelatedTransaction']($values, $related, $sql, 'contactid', false, array('priority'=>1));

                /*//need to handle transaction manually to account for errors WRT related data
                $app['db']->transactional(function($conn) use ($app, $values, $related, &$result) {
                    $sql = "
                        WITH contact as (
                            INSERT INTO contact(
                                    contactid, comment, dunsnumber, contacttypeid)
                                VALUES (DEFAULT, :comment, :dunsnumber, :contacttypeid)
                                RETURNING *
                        ), person as (INSERT INTO person(
                                    contactid, firstname, lastname, middlename, suffix, positionid)
                            SELECT contactid , :firstname, :lastname, :middlename, :suffix, :positionid
                            FROM contact
                            RETURNING *
                        )
                        SELECT * FROM contact,person;
                    ";

                    $stmt = $conn->prepare($sql);

                    foreach ($values as $k => $v)  {
                        $stmt->bindValue($k, $v);
                    }

                    $stmt->execute();

                    $result = $stmt->fetch(\PDO::FETCH_ASSOC);


                    $id = $result['contactid'];

                    //save related data
                    //TODO: create method for this
                    foreach ($related as $rClass => $rTable)  {
                        //we're assuming the primarykey is {tablename}id
                        $pk = $rTable['name'].'id';
                        if(isset($rTable['values'])) {
                            foreach ($rTable['values'] as $k => $v)  {
                                //set the fkey
                                $v->contactid = $id;
                                //save the related data and add returned data to the result array
                                $app['saveRelated']($v, $rTable['name'], $v->$pk);
                            }
                        }
                        //we return all of the related records, ExtJS associations require this
                        //TODO: remove priority when not needed
                        $result[$rClass] = $app['idiorm']->getRelated(true, $rTable['name'], 'contactid',$id ,
                            array('priority'=>1));

                    }

                    //return $result;
                });*/

                $app['json']->setData($result);
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll($result,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });

        $controllers->delete('person/{id}', function (Application $app, $id) use ($table) {
            $result = array();
            //need to delete from contact, delete will cascade
            try {
                $object = $app['idiorm']->getTable('contact')->find_one($id);
                if($object) {
                    $result = $object->as_array();

                    $object->delete();
                    $app['json']->setData($result);
                }else {
                    $message = "No record found in table '$table' with id of $id.";
                    $success = false;
                    $code = 404;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll($result,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
