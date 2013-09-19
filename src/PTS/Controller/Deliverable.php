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

        $controllers->get('deliverable/calendar', function (Application $app, Request $request) use ($table){
            $result = array();
            $table = 'deliverablecalendar'; //need to use Deliverablelist view
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
                        (deliverableid, personid, modificationid,duedate,receiveddate,startdate,enddate,publish,restricted,accessdescription,parentmodificationid,parentdeliverableid)
                        SELECT del.deliverableid,:personid, :modificationid, :duedate,:receiveddate,:startdate,:enddate,:publish,
                            :restricted,:accessdescription,:parentmodificationid,del.deliverableid
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
                        (deliverableid, personid, modificationid,duedate,receiveddate,startdate,enddate,publish,restricted,accessdescription,parentmodificationid,parentdeliverableid)
                        SELECT deliverableid,:personid, :modificationid, :duedate,:receiveddate,:startdate,:enddate,:publish,
                            :restricted,:accessdescription,:parentmodificationid,:parentdeliverableid
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

        return $controllers;
    }
}

?>
