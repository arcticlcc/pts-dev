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
        $controllers = new ControllerCollection();

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

        return $controllers;
    }
}

?>
