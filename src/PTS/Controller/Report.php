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

class Report implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];

        $controllers->get('report/tree', function (Application $app, Request $request) {

            try {
                //create root node($id,$text,$iconCls,$leaf)
                $rootNode = $app['tree']->node('root','.','',false);
                $node = $app['tree']->node(null,'Contact Reports','pts-agreement-folder',false);
                $rootNode->addChildren($app['reports'], $rootNode);
                $app['tree']->add($rootNode);

                $app['json']->setData($app['tree']->nodes[0]);

            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse(true);
        });

        $controllers->get('report/tps', function (Application $app, Request $request) {

            try {
                //grab all possible document types
                $doctypes = $app['idiorm']->getTable('moddoctype')->find_many();
                $fl = 'modificationid int,modificationcode varchar,shorttitle varchar, projectcode varchar, modtype varchar';
                
                $metadata = array('fields' => 
                    array(
                        'modificationid', 'modificationcode', 'shorttitle', 'projectcode', 'modtype'
                    ) 
                );
                
                //loop through and build field list for query
                foreach ($doctypes as $object) {
                    $fname = 'doctype_'. $object->moddoctypeid;
                    $fl .= ', '. $fname . ' varchar';
                    $metadata['fields'][] = $fname;
                }

                $sql = "SELECT *
                   FROM crosstab ('
                   SELECT * FROM report.allmoddocstatus',
                   'SELECT moddoctypeid
                   FROM moddoctype') AS ct(" . $fl . ")";
                
                $stmt = $app['db']->prepare($sql);
                $stmt->execute();
                $result = $stmt->fetchAll(\PDO::FETCH_ASSOC);
                
                $app['json']->setData($result);
                $app['json']->setMetadata($metadata);
                
            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
