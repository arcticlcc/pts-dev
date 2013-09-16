<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for modification statuses.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class ModStatus implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'modstatus';
        $strip = array(
            'weight' => true
        );

        $controllers->get('modstatus', function (Application $app, Request $request) use ($table){
            $table .= 'list'; //need to use modstatuslist view
            $query = $request->getQueryString(); //pass the query through

            return $app->redirect("/$table?$query");
        });

        $controllers->put('modstatus/{id}', function (Application $app, Request $request, $id) use ($table, $strip) {
            $result = array();

            $result = $app['saveTable']($request, $table, $id, true, $strip);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->post('modstatus', function (Application $app, Request $request) use ($table, $strip) {
            $result = array();
            $result = $app['saveTable']($request, $table, null, true, $strip);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
