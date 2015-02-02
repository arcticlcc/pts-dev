<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
//use League\OAuth2\Client\Provider;

/**
 * Controller hack for logins.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Login implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'login';

        $getSchemas = function ($loginid) use ($app){
            $query = $app['idiorm']->getTable('logingroupschema')
                    ->join('groupschema', array('logingroupschema.groupschemaid', '=', 'groupschema.groupschemaid'))
                    ->select('logingroupschema.groupschemaid')->select('displayname')
                    ->where('loginid',$loginid)
                    ->order_by_asc('priority');

            $result = $query->find_many();
            if(!$result) {
                throw new \Exception("That account is not authorized. Contact the system admin.");
            }
            foreach($result as $record) {
                $schemas[$record->groupschemaid] = $record->displayname;
            }
            return $schemas;
        };

        $controllers->get('login', function (Application $app, Request $request) use ($table){

            $app['session']->start();
            //set token
            $token = time();
            $app['session']->set('token', $token);
            //get page to redirect to if login is successful
            $redirect = $request->get('r');

            //show login
            return $app['twig']->render('login.twig', array(
                'token' => $token,
                'redirect' => $redirect,
                'salt' => $app['salt']
            ));

        });
        $controllers->post('login', function (Application $app, Request $request) use ($table, $getSchemas){
            $redirect = $request->get('r');
            $username = $app['request']->get('login_username', false);
            $password = $app['request']->get('login_spassword');
            $token = $app['request']->get('token');
            $stoken = $app['session']->get('token');

            //get password from database
            $query = $app['idiorm']->getTable('login')
                    ->join('logingroupschema', array('login.loginid', '=', 'logingroupschema.loginid'))
                    ->join('groupschema', array('logingroupschema.groupschemaid', '=', 'groupschema.groupschemaid'))
                    ->where('username',$username)
                    ->order_by_asc('priority');

            try {
                if((time() - $stoken) > 300 || $token != $stoken) {
                    throw new \Exception("Login timed out. Try again.");
                }

                $result = $query->find_one();

                if($result) {
                    $hash = hash_hmac("sha256",$result->password,$stoken,false);
                }else{
                    throw new \Exception("Try again. :-(");
                }

                if ($hash === $password) {
                    $app['session']->migrate(true); //regenerate the sessionid
                    $app['session']->replace(array(
                        'user' => array(
                            'username' => $result->username,
                            'loginid' => $result->loginid,
                            'firstname' => $result->firstname //TODO:Get this from database after setting path
                        ),
                        'schema' => $result->groupschemaid,
                        'schemas' => $getSchemas($result->loginid),
                        'deliverablecalid' => $result->deliverablecalendarid,
                        'email' => $result->email
                    ));

                    if($redirect) {
                        return $app->redirect($redirect);
                    }else {
                        return $app->redirect('/home');
                    }
                }

                throw new \Exception("Wrong. Try again.");

            } catch (\Exception $exc) {
                $msg = $exc->getMessage();
                $app['monolog']->addError($msg);

                //reset token
                $token = time();
                $app['session']->set('token', $token);

                //show login page with error
                return $app['twig']->render('login.twig', array(
                    'token' => $token,
                    'redirect' => $redirect,
                    'salt' => $app['salt'],
                    'message' => $msg
                ));
            }
        });

        $controllers->get('logout', function (Application $app, Request $request) {
            $app['session']->clear();
            $app['session']->invalidate(); //kill the old session

            //reset token
            $token = time();
            $app['session']->set('token', $token);

            //show login page with error
            return $app['twig']->render('login.twig', array(
                'token' => $token,
                'salt' => $app['salt'],
                'message' => "Logout successful.",
                'redirect' => false
            ));
        });

        $controllers->match('oauth2', function (Application $app, Request $request) use ($table, $getSchemas){
            $app['session']->start();
            $code = $request->get('code');
            $redirect = $request->get('r') ?: $app['session']->get('redirect');
            $provider = new \League\OAuth2\Client\Provider\Google(array(
                'clientId'  =>  $app['google']['webid'],
                'clientSecret'  =>  $app['google']['web_secret'],
                'redirectUri'   =>  'http://' . $_SERVER['HTTP_HOST'] . '/oauth2'
            ));

            if ( ! $code) {
                //store any redirect
                $app['session']->set('redirect', $redirect);
                // If we don't have an authorization code then get one
                $provider->authorize();

            } else {

                try {

                    // Try to get an access token (using the authorization code grant)
                    $t = $provider->getAccessToken('authorization_code', array('code' => $code));

                    // NOTE: If you are using Eventbrite you will need to add the grant_type parameter (see below)
                    // $t = $provider->getAccessToken('authorization_code', array('code' => $_GET['code'], 'grant_type' => 'authorization_code'));

                    try {

                        // We got an access token, let's now get the user's details
                        $userDetails = $provider->getUserDetails($t);
                        $first = $userDetails->firstName;
                        $last = $userDetails->lastName;
                        $email = $userDetails->email;

                        //get user from database
                        $query = $app['idiorm']->getTable('login')
                                ->join('logingroupschema', array('login.loginid', '=', 'logingroupschema.loginid'))
                                ->join('groupschema', array('logingroupschema.groupschemaid', '=', 'groupschema.groupschemaid'))
                                ->where('lastname',$last) //TODO: Add first name to auth?
                                ->where('openid',$email)
                                ->order_by_asc('priority');

                        $result = $query->find_one();

                        if ($result) {
                            $app['session']->migrate(true); //regenerate the sessionid
                            $app['session']->replace(array(
                                    'user'=> array(
                                        'username' => $result->username,
                                        'loginid' => $result->loginid,
                                        'firstname' => $result->firstname
                                        ),
                                    'schema' => $result->groupschemaid,
                                    'schemas' => $getSchemas($result->loginid),
                            ));

                            if($redirect) {
                                return $app->redirect($redirect);
                            }else {
                                return $app->redirect('/home');
                            }
                        }else{
                            throw new \Exception('No login matched that Google account: '. $email . '
                                <a href="https://accounts.google.com/Login">Try using a different account.</a>');
                        }
                    } catch (\Exception $exc) {

                        // Failed to get user details
                        $msg = $exc->getMessage();
                        $app['monolog']->addError($msg);
                    }
                } catch (\Exception $exc) {

                    // Failed to get access token
                    // If you have a refesh token you can use it here:
                    //$grant = new \League\OAuth2\Client\Grant\RefreshToken();
                    //$t = $provider->getAccessToken($grant, array('refresh_token' => $refreshToken));

                    $msg = 'Google login failed. Try again.';
                    $app['monolog']->addError($msg);
                }

                //reset login token
                $token = time();
                $app['session']->set('token', $token);

                //show login page with error
                return $app['twig']->render('login.twig', array(
                    'token' => $token,
                    'redirect' => $redirect,
                    'salt' => $app['salt'],
                    'message' => $msg
                ));
            }
        })->method('GET|POST');

        $controllers->match('openid', function (Application $app, Request $request) use ($table, $getSchemas){
            $app['session']->start();
            $init = $request->get('init');
            $redirect = $request->get('r');

            try {
                if($init){
                    $app['tryOpenIDAuth']($redirect);
                    //reset token
                    $token = time();
                    $app['session']->set('token', $token);
                    //show login page with error
                    return $app['twig']->render('login.twig', array(
                        'token' => $token,
                        'redirect' => $redirect,
                        'salt' => $app['salt'],
                        'message' => 'Please wait...contacting Google.'
                    ));
                }elseif($obj = $app['finishOpenIDAuth']()) {
                    $first = $obj->data['http://axschema.org/namePerson/first'][0];
                    $last = $obj->data['http://axschema.org/namePerson/last'][0];
                    $email = $obj->data['http://axschema.org/contact/email'][0];

                    //get user from database
                    $query = $app['idiorm']->getTable('login')
                            ->join('logingroupschema', array('login.loginid', '=', 'logingroupschema.loginid'))
                            ->join('groupschema', array('logingroupschema.groupschemaid', '=', 'groupschema.groupschemaid'))
                            ->where('lastname',$last) //TODO: Add first name to auth?
                            ->where('openid',$email)
                            ->order_by_asc('priority');

                    $result = $query->find_one();

                    if ($result) {
                        $app['session']->migrate(true); //regenerate the sessionid
                        $app['session']->replace(array(
                                'user'=> array(
                                    'username' => $result->username,
                                    'loginid' => $result->loginid,
                                    'firstname' => $result->firstname
                                    ),
                                'schema' => $result->groupschemaid,
                                'schemas' => $getSchemas($result->loginid),
                        ));

                        if($redirect) {
                            return $app->redirect($redirect);
                        }else {
                            return $app->redirect('/home');
                        }
                    }else{
                        throw new \Exception('No login matched that Google account: '. $email . '
                            <a href="https://accounts.google.com/Login">Try using a different account.</a>');
                    }
                }

                throw new \Exception("Google login failed. Try Again.");

            } catch (\Exception $exc) {
                $msg = $exc->getMessage();
                $app['monolog']->addError($msg);

                //reset token
                $token = time();
                $app['session']->set('token', $token);

                //show login page with error
                return $app['twig']->render('login.twig', array(
                    'token' => $token,
                    'redirect' => $redirect,
                    'salt' => $app['salt'],
                    'message' => $msg
                ));
            }
        })->method('GET|POST');

        return $controllers;
    }
}

?>
