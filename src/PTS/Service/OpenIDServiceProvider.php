<?php

namespace PTS\Service;

use Silex\Application;
use Silex\ServiceProviderInterface;

/**
 * Support for OpenID login. Just Google for now.
 *
 * @uses ServiceProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class OpenIDServiceProvider implements ServiceProviderInterface {
    /**
     * This is where the app will store its OpenID information.
     * You should change this path if you want the store to be
     * created elsewhere.
     */
    public function getStore() {

        $store_path = null;
        if (function_exists('sys_get_temp_dir')) {
            $store_path = sys_get_temp_dir();
        } else {
            if (strpos(PHP_OS, 'WIN') === 0) {
                $store_path = $_ENV['TMP'];
                if (!isset($store_path)) {
                    $dir = 'C:\Windows\Temp';
                }
            } else {
                $store_path = @$_ENV['TMPDIR'];
                if (!isset($store_path)) {
                    $store_path = '/tmp';
                }
            }
        }
        $store_path .= DIRECTORY_SEPARATOR . '_openid_store';

        if (!file_exists($store_path) && !mkdir($store_path)) {
            throw new \Exception("Could not create the FileStore directory '$store_path'. " . " Please check the effective permissions.");
        }
        $r = new \Auth_OpenID_FileStore($store_path);

        return $r;

    }

    /**
     * Create a consumer object using the store object.
     */
    public function getConsumer() {
        $store = $this -> getStore();
        $r = new \Auth_OpenID_Consumer($store);
        return $r;
    }

    public function getScheme() {
        $scheme = 'http';
        if (isset($_SERVER['HTTPS']) and $_SERVER['HTTPS'] == 'on') {
            $scheme .= 's';
        }
        return $scheme;
    }

    public function getSelf() {
        return '/' == dirname($_SERVER['PHP_SELF']) || '\\' == dirname($_SERVER['PHP_SELF'])? '' : dirname($_SERVER['PHP_SELF']);
    }

    public function getReturnTo($r=false) {
        return sprintf("%s://%s:%s%s/openid?r=%s", $this -> getScheme(), $_SERVER['SERVER_NAME'], $_SERVER['SERVER_PORT'], $this->getSelf(), $r);
    }

    public function getTrustRoot() {
        return sprintf("%s://%s:%s%s", $this -> getScheme(), $_SERVER['SERVER_NAME'], $_SERVER['SERVER_PORT'], $this->getSelf());
    }

    public function register(Application $app) {
        $that = $this;
        
        $app['tryOpenIDAuth'] = $app -> protect(function($redirect) use ($app, $that) {
            $openid = trim($app['openid.uri']);
            $consumer = $that->getConsumer();
    
            // Begin the OpenID authentication process.
            $auth_request = $consumer -> begin($openid);
            // No auth request means we can't begin OpenID.
            if (!$auth_request) {
                    throw new \Exception("Authentication error; not a valid OpenID.");
            }
    
            $ax = new \Auth_OpenID_AX_FetchRequest();
            
            // Add attributes to AX fetch request
            foreach($app['openid.attribute'] as $attr){
                $ax->add($attr);
            }
            
            if (!$ax) {
                    throw new \Exception("Unable to build AX Fetch Request");
            }
            $auth_request -> addExtension($ax);
       
            // Redirect the user to the OpenID server for authentication.
            // Store the token for this authentication so we can verify the
            // response.
    
            // For OpenID 1, send a redirect.  For OpenID 2, use a Javascript
            // form to send a POST request to the server.
            
            if ($auth_request -> shouldSendRedirect()) {
                    $redirect_url = $auth_request -> redirectURL(getTrustRoot(), getReturnTo($redirect));
    
                    // If the redirect URL can't be built, display an error
                    // message.
                    if (\Auth_OpenID::isFailure($redirect_url)) {
                            throw new \Exception("Could not redirect to server: " . $redirect_url -> message);
                    } else {
                            // Send redirect.
                            header("Location: " . $redirect_url);
                    }
            } else {
                    // Generate form markup and render it.
                    $form_id = 'openid_message';
                    $form_html = $auth_request -> htmlMarkup($that->getTrustRoot(), $that->getReturnTo($redirect), false, array('id' => $form_id));
    
                    // Display an error if the form markup couldn't be generated;
                    // otherwise, render the HTML.
                    if (\Auth_OpenID::isFailure($form_html)) {
                            throw new \Exception("Could not redirect to server: " . $form_html -> message);
                    } else {
                            print $form_html;
                    }
            }
        });
        
        $app['finishOpenIDAuth'] = $app -> protect(function() use ($app, $that) {
            $consumer = $that->getConsumer();
            // Complete the authentication process using the server's
            // response.
            $return_to = $that->getReturnTo();
            $response = $consumer->complete($return_to);
            // Check the response status.
            if ($response->status == \Auth_OpenID_CANCEL) {
                // This means the authentication was cancelled.
                throw new \Exception('Verification cancelled.');
            } else if ($response->status == \Auth_OpenID_FAILURE) {
                // Authentication failed; display the error message.
                throw new \Exception("OpenID authentication failed: " . $response->message);
            } else if ($response->status == \Auth_OpenID_SUCCESS) {
                // This means the authentication succeeded; extract the
                // identity URL and Simple Registration data (if it was
                // returned).
                /*$openid = $response->getDisplayIdentifier();
                */
                        
                // Get registration informations
                $ax = new \Auth_OpenID_AX_FetchResponse();
                return $ax->fromSuccessResponse($response,TRUE);
                                        
            }           
        });        
    }

    public function boot(Application $app) {
    }

}
?>