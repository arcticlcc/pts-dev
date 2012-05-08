<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for Funding.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Funding implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = new ControllerCollection();
        $table = 'funding';

        $controllers->get('funding/{id}/invoice', function (Application $app, Request $request, $id) {
            $table = 'invoicelist'; //need to use view
            $result = array();

            try {
                $result = $app['idiorm']->getRelated(true, $table, 'fundingid', $id);

                //we return the related costcode records as well, ExtJS associations require this
                foreach ($result as &$o)  {
                   $o['costcodes'] = $app['idiorm']->getRelated(true, 'costcodeinvoice', 'invoiceid', $o['invoiceid']);
                }

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
