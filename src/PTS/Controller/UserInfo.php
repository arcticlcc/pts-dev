<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for userinfo.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 *
 */

class UserInfo implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];

        $controllers->put('userinfo/config/{id}', function (Application $app, Request $request, $id) {

            try {
                //validate json
                $values = json_encode(json_decode($request->getContent()));

                $login = $app['idiorm']->getTable('login')->find_one($id);
                $login->config = $values;
                $login->save();

                $result =  array_merge($login->as_array('loginid'), (array) json_decode($login->config));
                $app['json']->setData($result);

            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
