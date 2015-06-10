<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for product contacts.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class ProductContact implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'productcontact';

        $controllers->put('productcontact/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();

            $result = $app['saveTable']($request, $table, $id, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->post('productcontact', function (Application $app, Request $request) use ($table) {
            $result = array();
            $result = $app['saveTable']($request, $table, null, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
