<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for PTS routes.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class PTS implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];

        $controllers->get('/pts/logout', function (Application $app, Request $request) {
            return $app->redirect("/logout");
        });

        $controllers->get('/pts/{schema}', function (Application $app, Request $request, $schema) {
            $user = $app['session']->get('user');

            try{
                $schemas = $app['session']->get('schemas');

                if(!isset($schemas[$schema])) {
                    throw new \Exception("Access is not authorized ($schema).");
                }

                $app['session']->set('schema',$schema);
                //get calendarids from database
                $result = $app['idiorm']->getTable('groupschema')
                        ->where('groupschemaid',$schema)->find_one();
                $app['session']->set('deliverablecalid',$result->deliverablecalendarid);
                $app['session']->set('email',$result->email);
                $app['session']->set('emailalias',$result->emailalias);

                $twig = $app['debug'] ? 'pts.twig' : 'pts.prod.twig';
                return $app['twig']->render($twig, array(
                    'loginid' => $user['loginid'],
                    'paths' => $schemas,
                    'apptitle' => $schemas[$schema],
                    'baseURL' => $app['baseURL']
                ));
            } catch(\Exception $exc) {
                $msg = $exc->getMessage();
                $app['monolog']->addError($msg);

                //show home page with error
                return $app['twig']->render('home.twig', array(
                    'message' => $msg,
                    'name' => $user['firstname'],
                    'paths' => $schemas
                ));
            }
        });

        $controllers->get('/pts/', function (Application $app, Request $request) {
            $schema = $app['session']->get('schema');

            return $app->redirect('/pts/'. $schema);
        });

        return $controllers;
    }
}

?>
