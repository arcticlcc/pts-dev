<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

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
        $controllers->post('login', function (Application $app, Request $request) use ($table){
            $redirect = $request->get('r');
            $username = $app['request']->get('login_username', false);
            $password = $app['request']->get('login_spassword');
            $token = $app['request']->get('token');
            $stoken = $app['session']->get('token');

            //get password from database
            $query = $app['idiorm']->getTable('login')
                    ->join('person', array('login.contactid', '=', 'person.contactid'))
                    ->where('username',$username);

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
                    $app['session']->set('user', array(
                        'username' => $result->username,
                        'loginid' => $result->loginid,
                        'firstname' => $result->firstname
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

        $controllers->match('openid', function (Application $app, Request $request) use ($table){
            $init = $request->get('init');
            $redirect = $request->get('r');


            //get e-mail from database
            /*$query = $app['idiorm']->getTable('login')
                    ->join('person', array('login.contactid', '=', 'person.contactid'))
                    ->where('username',$username);*/

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
                            ->join('person', array('login.contactid', '=', 'person.contactid'))
                            //->where('firstname',$first)
                            ->where(strtolower('username'),strtolower($last))
                            ->where('openid',$email);
                            
                    $result = $query->find_one();
                                                                   
                    if ($result) {
                        $app['session']->migrate(true); //regenerate the sessionid
                        $app['session']->set('user', array(
                            'username' => $result->username,
                            'loginid' => $result->loginid,
                            'firstname' => $result->firstname
                        ));
                        if($redirect) {
                            return $app->redirect($redirect);
                        }else {
                            return $app->redirect('/home');
                        }
                    }else{
                        throw new \Exception("Login failed. No login matched the Google account.");                        
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
