<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for project contacts.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class ProjectContact implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = new ControllerCollection();
        $table = 'projectcontact';

        $controllers->get('projectcontact', function (Application $app, Request $request) use ($table){
            $table .= 'list'; //need to use projectcontactlist view
            $query = $request->getQueryString(); //pass the query through

            return $app->redirect("/$table?$query");
        });

        $controllers->put('projectcontact/{id}', function (Application $app, Request $request, $id) use ($table) {
            $result = array();

            $result = $app['saveTable']($request, $table, $id, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        $controllers->post('projectcontact', function (Application $app, Request $request) use ($table) {
            $result = array();
            $result = $app['saveTable']($request, $table, null, true);
            $app['json']->setData($result);

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
