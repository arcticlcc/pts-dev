<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for Invoices.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Invoice implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = new ControllerCollection();
        $table = 'invoice';
        $related = array(
            'costcodes'=>array('name' =>'costcodeinvoice')
        );

        $controllers->get('invoice/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();

            try {
                $object = $app['idiorm']->getTable($table)
                    ->find_one($id);

                //get associated costcodes
                $costcodes = $app['idiorm']->getRelated(true, 'costcodeinvoice', 'invoiceid', $id);

                if($object) {
                    $result = $object->as_array();
                    $result['costcodes'] = $costcodes;
                    $app['json']->setData($result);
                }else {
                    $message = "No record found in table '$table' with id of $id.";
                    $success = false;
                    $code = 404;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll($result,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });

        $controllers->put('invoice/{id}', function (Application $app, Request $request, $id) use ($related, $table) {
            $result = array();

            try {
                $values = json_decode($request->getContent());

                $app['mergeRelated']($related, $values);
                $result = $app['saveRelatedTransaction']($values, $related, $table, 'invoiceid', $id);
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

        $controllers->post('invoice', function (Application $app, Request $request) use ($related, $table) {
            $result = array();

            try {
                $values = json_decode($request->getContent());

                $app['mergeRelated']($related, $values);
                $result = $app['saveRelatedTransaction']($values, $related, $table, 'invoiceid');
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
