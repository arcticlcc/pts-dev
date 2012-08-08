<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for groups(contacts).
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class ContactGroup implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = new ControllerCollection();
        $table = 'contactgroup';
        $related = array(
            'addresses'=>array('name' =>'address'),
            'eaddresses'=>array('name' => 'eaddress'),
            'phones'=>array('name' => 'phone'),
            'contactcontactgroups'=>array('name' => 'contactcontactgroup')
        );
 //TODO: replace redirect with new method in PTS provider
        $controllers->get('contactgroup', function (Application $app, Request $request) use ($table){
            $table .= 'list'; //need to use projectcontactlist view
            $query = $request->getQueryString(); //pass the query through

            return $app->redirect("/$table?$query");
        });

        $controllers->get('contactgroup/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();
            $table .= 'list';

            try {
                $object = $app['idiorm']->getTable($table)
                    ->join('contact', array("$table.contactid", '=', 'contact.contactid'))
                    ->where("$table.contactid", $id)
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

                //get primary parent group, assumes priority is set to 1
                $ccgroup = $app['idiorm']->getRelated(true, 'contactcontactgroup', 'contactid', $id,
                    array('priority'=>1));

                if($object) {
                    $result = $object->as_array();
                    $result['addresses'] = $addresses;
                    $result['phones'] = $phones;
                    $result['eaddresses'] = $eaddresses;
                    $result['contactcontactgroups'] = $ccgroup;
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

        $controllers->get('contactgroup/{id}/person', function (Application $app, Request $request, $id) {
            $table = 'grouppersonlist';
            //$query = array('modtypeid' => 4);

            $app['getRelated']($request, $table, 'groupid', $id);

            return $app['json']->getResponse();
        });

        $controllers->get('contactgroup/{id}/member', function (Application $app, Request $request, $id) {
            $table = 'groupmemberlist'; //need to use groupmemberlist view

            $app['getRelated']($request, $table, 'groupid', $id);

            return $app['json']->getResponse();
        });

        $controllers->put('contactgroup/{pid}/member/{id}', function (Application $app, Request $request, $pid, $id) {
            $table = 'contactcontactgroup';
            $result = array();

            $result = $app['saveTable']($request, $table, $id, 'groupmemberlist');
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->post('contactgroup/{id}/member', function (Application $app, Request $request) {
            $table = 'contactcontactgroup'; //need to use membergrouplist view
            $result = array();

            $result = $app['saveTable']($request, $table, null, 'groupmemberlist');
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->put('contactgroup/{id}', function (Application $app, Request $request, $id) use ($related) {
            $result = array();

            try {
                $values = json_decode($request->getContent());
                $app['mergeRelated'](&$related, &$values);

                $sql = "
                    WITH contact as (UPDATE contact
                        SET comment=:comment, dunsnumber=:dunsnumber, contacttypeid=:contacttypeid, inactive=:inactive
                        WHERE contactid = :contactid
                        RETURNING *
                    ), contactgroup as (UPDATE contactgroup
                        SET organization=:organization, name=:name, acronym=:acronym
                        WHERE contactid = :contactid
                        RETURNING *
                    )
                    SELECT * FROM contact,contactgroup;
                ";

                $result = $app['saveRelatedTransaction']($values, $related, $sql, 'contactid', $id);
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

        $controllers->post('contactgroup', function (Application $app, Request $request) use ($related) {

            $result = array();

            try {
                $values = json_decode($request->getContent());
                $app['mergeRelated'](&$related, &$values);

                $sql = "
                    WITH contact as (
                        INSERT INTO contact(
                                contactid, comment, dunsnumber, contacttypeid, inactive)
                            VALUES (DEFAULT, :comment, :dunsnumber, :contacttypeid, :inactive)
                            RETURNING *
                    ), contactgroup as (INSERT INTO contactgroup(
                                contactid, organization, name, acronym)
                        SELECT contactid , :organization, :name, :acronym
                        FROM contact
                        RETURNING *
                    )
                    SELECT * FROM contact,contactgroup;
                ";

                $result = $app['saveRelatedTransaction']($values, $related, $sql, 'contactid');
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

        $controllers->delete('contactgroup/{id}', function (Application $app, $id) use ($table) {
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
