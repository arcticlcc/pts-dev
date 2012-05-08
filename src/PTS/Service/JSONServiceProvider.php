<?php

namespace PTS\Service;

use Silex\Application;
use Silex\ServiceProviderInterface;
use Symfony\Component\HttpFoundation\Response;

/**
 * A quick and dirty service provider to render a JSON response.
 * 
 * @uses ServiceProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class JSONServiceProvider implements ServiceProviderInterface
{
    public function register(Application $app)
    {
        $app['json'] = $app->protect(function (array $data, $status_code = 200) use ($app) {
            return new Response(json_encode($data), $status_code, array(
                'Content-type' => 'application/json'
            ));
        });
        
        $app['extJson'] = $app->protect(function (array $data = null, $status_code = 200, $success=true, $msg = false) use ($app) {
            $json = array(
                'success' => $success,
            );
            
            if($data) {
                $json['data'] = $data;
            }
            
            if($msg) {
                $json['message'] = $msg;
            }elseif(!$success) {
                $json['message'] = 'Error.';
            }
                    
            return new Response(json_encode($json), $status_code, array(
                'Content-type' => 'application/json'
            ));
        });        
    }
} 
 
?>
