<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

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
        $controllers = new ControllerCollection();
        $table = 'modification';


        $controllers->get('modification/{modid}/deliverable/{id}', function (Application $app, Request $request, $modid, $id) use ($table){
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
                        SET deliverabletypeid=:deliverabletypeid, title=:title, description=:description
                        WHERE deliverableid = :deliverableid
                        RETURNING *
                    ), dmod as (UPDATE deliverablemod
                        SET  duedate = :duedate,
                          receiveddate = :receiveddate,
                          invalid = :invalid,
                          publish = :publish,
                          restricted = :restricted,
                          personid = :personid,
                          accessdescription = :accessdescription,
                          parentmodificationid = :parentmodificationid,
                          parentdeliverableid = :parentdeliverableid
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
                $app['monolog']->addError($exc->getMessage());
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

//var_dump($mod);exit;
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

                    }else { //we're deleing the root deliverable, so that's done from the deliverables table
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
                    $app['monolog']->addError($exc->getMessage());
                    $message = $exc->getMessage();
                    $success = false;
                    $code = 400;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            }
            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
