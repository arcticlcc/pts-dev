<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for reports.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 *
 */

class Report implements ControllerProviderInterface {
    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];

        $controllers->get('report/tree', function(Application $app, Request $request) {

            try {
                //create root node($id,$text,$iconCls,$leaf)
                $rootNode = $app['tree']->node('root', '.', '', false);
                $node = $app['tree']->node(null, 'Contact Reports', 'pts-agreement-folder', false);
                $rootNode->addChildren($app['reports'], $rootNode);
                $app['tree']->add($rootNode);

                $app['json']->setData($app['tree']->nodes[0]);

            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse(true);
        });

        $controllers->get('report/tps.{format}', function(Application $app, Request $request, $format) {
            $result = array();

            try {
                //grab all possible document types
                $doctypes = $app['idiorm']->getTable('moddoctype')->find_many();
                $fl = 'modificationid int, projectid int,modificationcode varchar,title varchar,shorttitle varchar, projectcode varchar, modtype varchar, status varchar, weight int';

                $metadata = array(
                    'fields' => array(
                        'modificationid',
                        'projectid',
                        'modificationcode',
                        'title',
                        'shorttitle',
                        'projectcode',
                        'modtype'
                    ),
                    'idProperty' => 'modificationid'
                );

                //loop through and build field list for query
                foreach ($doctypes as $object) {
                    $fname = 'doctype_' . $object->moddoctypeid;
                    $fl .= ', ' . $fname . ' varchar';
                    $metadata['fields'][] = $fname;
                }

                $sql = "(SELECT *
                   FROM crosstab ('
                   SELECT modificationid, projectid, modificationcode, title, shorttitle, projectcode, modtype,
                                            status, COALESCE(weight,-1) ,moddoctypeid, code FROM allmoddocstatus',
                   'SELECT moddoctypeid
                   FROM moddoctype') AS ct(" . $fl . "))";

                $query = $app['idiorm']->getTable($sql)->subquery()->table_alias('q');

                //create the count query with only filters applied
                $count = clone $app['applyParams']($request, $query, true);

                //add sorting and paging to query
                $app['applyParams']($request, $query, false, true, true);

                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }

                //$queryBuilder = $app['db']->createQueryBuilder();

                /*$stmt = $app['db']->prepare($sql);
                 $stmt->execute();
                 $result = $stmt->fetchAll(\PDO::FETCH_ASSOC);*/

                $app['json']->setMetadata($metadata);

                switch ($format) {
                    case "csv" :
                        $app['csv']->setTitle('TPS Report');
                        break;
                    default :
                        $app[$format]->setTotal($count->count());
                }

                $response = $app[$format]->setData($result)->getResponse();

            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $response;

        })->value('format', 'json');

        return $controllers;
    }

}
?>
