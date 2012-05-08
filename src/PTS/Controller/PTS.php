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
        $controllers = new ControllerCollection();
            
        $controllers->get('/pts/', function (Application $app, Request $request) {
            $user = $app['session']->get('user');
            
            return $app['twig']->render('pts.twig', array(
                'loginid' => $user['loginid']
            ));
        });                    

        $controllers->get('/pts/logout', function (Application $app, Request $request) {
            return $app->redirect("/logout");
        }); 
                                                                         
        return $controllers;
    }
}

?>
