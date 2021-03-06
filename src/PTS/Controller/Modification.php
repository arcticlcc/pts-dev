<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

/**
 * Controller for project contacts.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Modification implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'modification';

        $controllers->get('modification/{modid}', function (Application $app, Request $request, $modid) {
            $uri = "/modificationlist/$modid"; //need to use modificationlist view

            $subRequest = Request::create($uri, 'GET', $request->query->all(), $request->cookies->all(), array(), $request->server->all());
            if ($request->getSession()) {
                $subRequest->setSession($request->getSession());
            }

            $response = $app->handle($subRequest, HttpKernelInterface::SUB_REQUEST, TRUE);
            return $response;
        });

        //need to return list
        $controllers->put('modification/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();

            $result = $app['saveTable']($request, $table, $id, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        //need to return list
        $controllers->post('modification', function (Application $app, Request $request) use ($table) {
            $result = array();
            $result = $app['saveTable']($request, $table, null, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->get('modification/{modid}/modstatus', function (Application $app, Request $request, $modid) {
            $table = 'modstatuslist'; //need to use modstatuslist view
            $query = array('modificationid' => $modid);

            $app['getRelated']($request, $table, 'modificationid', $modid, $query);

            return $app['json']->getResponse();
        });

        $controllers->get('modification/{modid}/moddoctype/{dtypeid}/moddocstatus', function (Application $app, Request $request, $modid, $dtypeid) {
            $table = 'moddocstatuslist'; //need to use moddocstatuslist view
            $query = array('modificationid' => $modid, 'moddoctypeid' => $dtypeid);

            $app['getRelated']($request, $table, 'modificationid', $modid, $query);

            return $app['json']->getResponse();
        });

        $controllers->get('modification/{modid}/deliverable/{id}', function (Application $app, Request $request, $modid, $id) {
            $table = 'deliverableall';
            $query = array('modificationid' => $modid);

            $app['getRelated']($request, $table, 'deliverableid', $id, $query);

            return $app['json']->getResponse();
        });

        $controllers->put('modification/{modid}/deliverable/{id}', function (Application $app, Request $request, $modid, $id) use ($table){
            $result = array();

            try {
                $values = json_decode($request->getContent());
                $sql = "
                    WITH del as (UPDATE deliverable
                        SET deliverabletypeid=:deliverabletypeid, title=:title, description=:description, code=:code
                        WHERE deliverableid = :deliverableid
                        RETURNING *
                    ), dmod as (UPDATE deliverablemod
                        SET  duedate = :duedate,
                          receiveddate = :receiveddate,
                          startdate = :startdate,
                          enddate = :enddate,
                          publish = :publish,
                          restricted = :restricted,
                          personid = :personid,
                          accessdescription = :accessdescription,
                          parentmodificationid = :parentmodificationid,
                          parentdeliverableid = :parentdeliverableid,
                          reminder = :reminder,
                          staffonly = :staffonly
                        WHERE modificationid = :modificationid
                            AND deliverableid = :deliverableid
	                RETURNING *
                    )
                    SELECT * FROM del,dmod;
                ";
                $stmt = $app['db']->prepare($sql);

                foreach ($values as $k => $v)  {
                    //TODO: Add PDO type check to other bind statements
                    $stmt->bindValue($k, $v,$app['util']->getPDOConstantType($v));
                }
                $stmt->bindValue('deliverableid', $id);
                $stmt->execute();
                $result = $stmt->fetch(\PDO::FETCH_ASSOC);

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

        $controllers->delete('modification/{modid}/deliverable/{id}', function (Application $app, Request $request, $modid, $id) {
            //we need to check if the deliverable has been modified
            $mod = $app['idiorm']->getTable('deliverableall')
                ->where('modificationid', $modid)
                ->where('deliverableid', $id)
                ->find_one();

            if($mod->modified) {
                // cannot delete a record with existing mods
                $message = "This deliverable has been modified. Please delete modifications before deleting this record.";
                $app['json']->setAll(null,409,false,$message);
            }else {
                try {
                    //delete the d

                    if($mod->parentdeliverableid) { //check to see if we're deleting a modification
                        $sql = 'DELETE FROM deliverablemod
                                WHERE modificationid = :modid
                                AND deliverableid = :id
                                RETURNING *';
                        $data = array('modid'=>$modid , 'id'=>$id);

                        $object = $app['idiorm']->getTable('deliverablemod')
                        ->raw_query($sql,$data)
                        ->find_one();

                    }else { //we're deleting the root deliverable, so that's done from the deliverables table
                        $object = $app['idiorm']->getTable('deliverable')->find_one($id);
                        $object->delete();
                    }

                    if($object) {
                        $result = $object->as_array();
                        $app['json']->setData($result);
                    }else {
                        $message = "No record found in table '$table' with id of $id.";
                        $success = false;
                        $code = 404;
                        $app['json']->setAll($result,$code,$success,$message);
                    }
                } catch (Exception $exc) {
                    $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
                    $message = $exc->getMessage();
                    $success = false;
                    $code = 400;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            }
            return $app['json']->getResponse();
        });

        $controllers->match('modificationcontact/{id}', function (Application $app, Request $request, $id) {
            try{
                $app['db']->transactional(function($conn) use ($app, $request, $id) {
                    $values = json_decode($request->getContent());
                    $modcontact = $app['idiorm']->getTable('modificationcontact');

                    if($request->getMethod() === 'PUT') {
                        //delete any existing records
                        $modcontact->where_equal('modificationid', $id)->delete_many();

                    }

                    //create new records based on submitted data
                    foreach ($values->modificationcontact as $key => $value) {
                        $modcontact->create();
                        $modcontact->set('modificationid', $id);
                        $modcontact->set('projectcontactid', $value);
                        $modcontact->set('priority', $key);
                        $modcontact->save();
                    }

                });

                $object = $app['idiorm']->getTable('modificationcontactlist')->find_one($id);
                $result = $object->as_array();
                $app['json']->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
                $app['json']->setAll(null, 500, false, $exc->getMessage());
            }

            return $app['json']->getResponse();

        })->method('PUT');

        return $controllers;
    }
}

?>
