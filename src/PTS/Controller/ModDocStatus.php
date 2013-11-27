<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for modification document statuses.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class ModDocStatus implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'moddocstatus';
        $strip = array(
            'weight' => true
        );

        $controllers->put('moddocstatus/{id}', function (Application $app, Request $request, $id) use ($table, $strip) {
            $result = array();

            $result = $app['saveTable']($request, $table, $id, true, $strip);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->post('moddocstatus', function (Application $app, Request $request) use ($table, $strip) {
            $result = array();
            $result = $app['saveTable']($request, $table, null, true, $strip);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
