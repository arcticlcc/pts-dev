<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

/**
 * Controller for product.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Product implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'product';

        $controllers->match('productmetadata/{id}', function (Application $app, Request $request, $id) {
            try{
                $app['db']->transactional(function($conn) use ($app, $request, $id) {
                    $values = json_decode($request->getContent());
                    $topic = $app['idiorm']->getTable('producttopiccategory');

                    if($request->getMethod() === 'PUT') {
                        //delete any existing records
                        $topic->where_equal('productid', $id)->delete_many();
                    }

                    //create new records based on submitted data
                    foreach ($values->topiccategory as $value) {
                        $topic->create();
                        $topic->set('productid', $id);
                        $topic->set('topiccategoryid',$value);
                        $topic->save();
                    }

                });

                $object = $app['idiorm']->getTable('productmetadata')->find_one($id);
                $result = $object->as_array();
                $app['json']->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $app['json']->setAll(null, 500, false, $exc->getMessage());
            }

            return $app['json']->getResponse();

        })->method('PUT');

        $controllers->get('product/{id}/metadata.{format}', function (Application $app, Request $request, $id, $format) {
            try{
                $json = $app['adiwg']->renderProduct($app['adiwg']->getProduct($id, TRUE));
                $ct = "application/$format";

                switch ($format) {
                    case 'xml':
                        $out = $app['adiwg']->translate($json);
                        break;
                    case 'html':
                        $out = $app['adiwg']->translate($json, 'html');
                        $ct = "text/html";
                        break;
                    case 'json':
                    default:
                       $out = $request->get('pretty') ? json_encode(json_decode($json), JSON_PRETTY_PRINT) : $json;
                }

                $response = new Response($out, 200, array(
                    'Content-type' => "$ct; charset=utf-8"
                ));
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $response = $app['json']->setAll(null, 500, false, $exc->getMessage())->getResponse();
            }

            return $response;

        })->value('format', 'json');

        $controllers->match('product/{id}/metadata/publish', function (Application $app, Request $request, $id) {
            try{
                $app['adiwg']->saveProduct($id);

                $json[] = array('success' => true);
                $response = $app['json']->setData($json)->getResponse(true);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $response = $app['json']->setAll(null, 500, false, $exc->getMessage())->getResponse();
            }

            return $response;

        })->method('GET|PUT|POST');

        $controllers->match('product/{id}/metadata/publish', function (Application $app, Request $request, $id) {
            try{
                $app['adiwg']->deleteProduct($id);

                $json[] = array('success' => true);
                $response = $app['json']->setData($json)->getResponse(true);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $response = $app['json']->setAll(null, 500, false, $exc->getMessage())->getResponse();
            }

            return $response;

        })->method('DELETE');

        return $controllers;
    }


}

?>
