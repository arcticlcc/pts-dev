<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Controller for country table.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Country implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = new ControllerCollection();
        $table = 'country';

        $controllers->get('country/{id}/postalcode/{rid}', function (Application $app, Request $request, $id, $rid) use ($table){

            $app['getFirstRelated']($request, 'postalcodelist', 'countryiso', $id, array('postalcode'=>$rid));

            if(!$app['json']->getSuccess()) {
                //Override the statuscode to prevent error msgbox in Extjs PTS client
                //TODO: fix this so we can return a valid http error, i.e. 404
                //$app['json']->setStatusCode(200);
                $app['json']->setMessage("No record found for country '$id' and postalcode '$rid'");
            }

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}

?>
