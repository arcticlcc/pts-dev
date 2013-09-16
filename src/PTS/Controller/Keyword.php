<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for keywords.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 *
 */

class Keyword implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'projectkeyword';

        $controllers->get('keyword/tree', function (Application $app, Request $request) {

            try {
                //create root node($id,$text,$iconCls,$leaf)
                $rootNode = $app['tree']->node('root','.','',false);
                //get base nodes
                $query = $app['idiorm']->getTable('keywordtree')
                    ->where_null('parentkeywordid');
                //$node = $app['tree']->node(null,'Contact Reports','pts-agreement-folder',false);
                foreach ($query->find_many() as $object) {
                    $object->allowDrag = false;
                    $result[] = $object->as_array();
                }
                $rootNode->addChildren($result, $rootNode);
                $app['tree']->add($rootNode);

                $app['json']->setData($app['tree']->nodes[0]);

            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse(true);
        });

        $controllers->get('keyword/tree/{id}', function (Application $app, Request $request, $id) {

            try {

                    $app['getRelated']($request, 'keywordtree', 'parentkeywordid', $id);
               /* //create root node($id,$text,$iconCls,$leaf)
                $rootNode = $app['tree']->node('root','.','',false);
                //get base nodes
                $query = $app['idiorm']->getTable('keywordtree')
                    ->where_null('parentkeywordid');
                //$node = $app['tree']->node(null,'Contact Reports','pts-agreement-folder',false);
                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }
                $rootNode->addChildren($result, $rootNode);
                $app['tree']->add($rootNode);

                $app['json']->setData($app['tree']->nodes[0]);*/

            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse(true);
        });

        //need to return list
        $controllers->put('projectkeyword/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();

            $result = $app['saveTable']($request, $table, $id, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        //need to return list
        $controllers->post('projectkeyword', function (Application $app, Request $request) use ($table) {
            $result = array();
            $result = $app['saveTable']($request, $table, null, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
