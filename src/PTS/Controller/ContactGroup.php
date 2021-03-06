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
        $controllers = $app['controllers_factory'];
        $table = 'contactgroup';
        $related = array(
            'addresses'=>array('name' =>'address'),
            'eaddresses'=>array('name' => 'eaddress'),
            'phones'=>array('name' => 'phone'),
            'contactcontactgroups'=>array('name' => 'contactcontactgroup')
        );
 //TODO: replace redirect with new method in PTS provider
        $controllers->get('contactgroup.{format}', function (Application $app, Request $request, $format) use ($table){
            $table .= 'list'; //need to use projectcontactlist view
            $query = $request->getQueryString(); //pass the query through

            return $app->redirect("/$table.$format?$query");
        })->value('format', 'json');

        $controllers->get('contactgroup/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();
            $table .= 'list';

            try {
                $object = $app['idiorm']->getTable($table)
                    ->join('contact', array("$table.contactid", '=', 'contact.contactid'))
                    ->where("$table.contactid", $id)
                    ->find_one();

                //get primary mail/physical addresses
                $addresses = $app['idiorm']->getFirstRelated(true, 'address', 'contactid', $id,
                    array('addresstypeid' => 1),'priority','ASC');

                $addresses = array_merge($addresses, $app['idiorm']->getFirstRelated(true, 'address', 'contactid', $id,
                    array('addresstypeid' => 2),'priority','ASC'));

                //get primary office/mobile/fax phone#s
                $phones = $app['idiorm']->getFirstRelated(true, 'phone', 'contactid', $id,
                    array('phonetypeid' => 1),'priority','ASC');

                $phones = array_merge($phones, $app['idiorm']->getFirstRelated(true, 'phone', 'contactid', $id,
                    array('phonetypeid' => 2),'priority','ASC'));

                $phones = array_merge($phones, $app['idiorm']->getFirstRelated(true, 'phone', 'contactid', $id,
                    array('phonetypeid' => 3),'priority','ASC'));

                //get primary website and e-mail
                $eaddresses = $app['idiorm']->getFirstRelated(true, 'eaddress', 'contactid', $id,
                    array('eaddresstypeid' => 1),'priority','ASC');

                $eaddresses = array_merge($eaddresses, $app['idiorm']->getFirstRelated(true, 'eaddress', 'contactid', $id,
                    array('eaddresstypeid' => 2),'priority','ASC'));

                //get primary parent group
                $ccgroup = $app['idiorm']->getFirstRelated(true, 'contactcontactgroup', 'contactid', $id,
                    null, 'priority',' ASC');

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
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
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
                $app['mergeRelated']($related, $values);

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

                if(!empty($result['contactcontactgroups'])) {
                    //get fullname
                    $fullname = $app['idiorm']->getTable('contactgrouplist')
                                ->where('contactid', $result['contactid'])
                                ->find_one();
                    if($fullname) {
                        $result['fullname'] = $fullname->fullname;
                        $result['parentname'] = $fullname->parentname;
                        $result['parentgroupid'] = $fullname->parentgroupid;
                    }
                } else {
                    $result['fullname'] = $result['name'];
                };

                $app['json']->setData($result);
            } catch (\Exception $exc) {
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
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
                $app['mergeRelated']($related, $values);

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

                if(!empty($result['contactcontactgroups'])) {
                    //get fullname
                    $fullname = $app['idiorm']->getTable('contactgrouplist')
                                ->where('contactid', $result['contactid'])
                                ->find_one();
                    if($fullname) {
                        $result['fullname'] = $fullname->fullname;
                        $result['parentname'] = $fullname->parentname;
                        $result['parentgroupid'] = $fullname->parentgroupid;
                    }
                } else {
                    $result['fullname'] = $result['name'];
                };

                $app['json']->setData($result);
            } catch (\Exception $exc) {
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
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
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
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
