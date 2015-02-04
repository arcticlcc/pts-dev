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

class Deliverable implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'deliverable';

 //TODO: replace redirect with new method in Idiorm provider
        $controllers->get('deliverable', function (Application $app, Request $request) use ($table){
            $table .= 'list'; //need to use Deliverablelist view
            $query = $request->getQueryString(); //pass the query through

            return $app->redirect("/$table?$query");
        });

        $controllers->get('deliverable/calendar', function (Application $app, Request $request) {
            $result = array();
            $table = 'deliverablecalendar'; //need to use deliverablecalendar view
            $startDate = $request->get('startDate');
            $endDate = $request->get('endDate');

            try {

                if($startDate && $endDate) {
                    $query = $app['idiorm']->getTable($table)
                        ->where_gte('duedate', $startDate)
                        ->where_lte('duedate', $endDate);
                }else {
                    throw new \Exception("Please supply both start and end dates.");
                }

                $count = clone $query;

                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }

                $count = $count->count();

                $app['json']->setTotal($count);

                $app['json']->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse();

        });

        /*$controllers->put('deliverable/{id}', function (Application $app, Request $request, $id) {
            $app['put']($request, 'deliverable', $id);
        });*/

        $controllers->post('deliverable', function (Application $app, Request $request) use ($table){
            $result = array();

            try {
                $values = json_decode($request->getContent());
                //need to check if we're posting a "modification"
                if($values->parentmodificationid && $values->parentdeliverableid) {
                    $sql = "WITH del as (SELECT *
                        FROM deliverable
                        WHERE deliverableid = :parentdeliverableid
                    ), dmod as (INSERT INTO deliverablemod
                        (deliverableid, personid, modificationid,duedate,receiveddate,startdate,enddate,publish,restricted,accessdescription,parentmodificationid,parentdeliverableid,reminder)
                        SELECT del.deliverableid,:personid, :modificationid, :duedate,:receiveddate,:startdate,:enddate,:publish,
                            :restricted,:accessdescription,:parentmodificationid,del.deliverableid,:reminder
                        FROM del
                    RETURNING *
                    )
                    SELECT * FROM del,dmod;";
                    //get rid of extra params
                    unset($values->deliverabletypeid);
                    unset($values->title);
                    unset($values->description);
                }else {
                    $sql = "WITH del as (INSERT INTO deliverable
                        (deliverabletypeid, title, description)
                        VALUES (:deliverabletypeid, :title, :description)
                        RETURNING *
                    ), dmod as (INSERT INTO deliverablemod
                        (deliverableid, personid, modificationid,duedate,receiveddate,startdate,enddate,publish,restricted,accessdescription,parentmodificationid,parentdeliverableid,reminder)
                        SELECT deliverableid,:personid, :modificationid, :duedate,:receiveddate,:startdate,:enddate,:publish,
                            :restricted,:accessdescription,:parentmodificationid,:parentdeliverableid,:reminder
                        FROM del
                    RETURNING *
                    )
                    SELECT * FROM del,dmod;";
                }
                $stmt = $app['db']->prepare($sql);

                foreach ($values as $k => $v)  {
                    //TODO: Add PDO type check to other bind statements
                    $stmt->bindValue($k, $v,$app['util']->getPDOConstantType($v));
                }
                //$stmt->bindValue('deliverableid', $id);
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

        $controllers->match('deliverable/calendar/event/{id}', function (Application $app, Request $request, $id) {
            $values = json_decode($request->getContent());
            $calId = isset($values->calendar) ? $values->calendar : $app['session']->get('deliverablecalid');

            $object = $app['idiorm']->getTable('deliverablecalendar')->where('deliverableid',$values->deliverableid)->find_one();
            $eventData = $app['eventData']($object);

            try {
                $event = $app['createEvent']($eventData, $calId);
                if($id) {
                    $app['updateEvent']($event, $calId);
                } else {
                    $app['insertEvent']($event, $calId);
                }

                $json[] = array('success' => true);
                $app['json']->setData($json)->getResponse(true);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
            }

            return $app['json']->getResponse();
        })
        ->value('id', FALSE)
        ->method('PUT|POST');

        $controllers->delete('deliverable/calendar/event/{id}', function (Application $app, Request $request, $id) {
            $values = json_decode($request->getContent());
            $calId = isset($values->calendar) ? $values->calendar : $app['session']->get('deliverablecalid');

            try {
                $result = $app['deleteEvent'](bin2hex($app['session']->get('schema') . '-' . $id), $calId);

                $json[] = array('success' => true);
                $app['json']->setData($json)->getResponse(true);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });

        $controllers->match('deliverable/calendar/sync', function (Application $app, Request $request) {
            $calendar = ($request->query->get('calendar') ?: $request->request->get('calendar')) ?: $app['session']->get('deliverablecalid');

            try {
                $query = $app['idiorm']->getTable('deliverablecalendar');

                $events = $query->find_many();

                /*foreach ($events as $object) {
                    var_dump($object->as_array());
                }*/


                $result = $app['gcalSync']($events, $calendar);

                $app['json']->setData($result)->getResponse(true);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });

        $controllers->match('deliverable/{id}/reminder', function (Application $app, Request $request, $id) {

            $template = ($request->query->get('template'));
            try {
                $object = $app['idiorm']->getTable('deliverablereminder')
                    //->join('contact', array('person.contactid', '=', 'contact.contactid'))
                    //->where('person.contactid', $id)
                    ->find_one($id);

                if($object) {
                    $data = $object->as_array();
                    $delid = $data['deliverabletypeid'];

                    //cc admin if a financial report
                    $data['ccadmin']  = in_array($delid, [6,25]) ? TRUE : FALSE;
                    //set template
                    if(!$template) {
                        $template = $app['notice.getTemplateId']($delid);
                    }
                    $notice = $app['renderNotice']($data, $template);
                    $resp = $app['sendMail']($notice);
                    $app['recordNotice']($data);
                    $app['json']->setMessage($resp);
                }else {
                    $message = "No deliverable found with id of $id.";
                    $success = false;
                    $code = 404;
                    $app['json']->setAll(null,$code,$success,$message);
                }

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
            }

            return $app['json']->getResponse();

        })->method('PUT|POST');

        return $controllers;
    }
}

?>
