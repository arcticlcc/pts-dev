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
                        'deliverablecalid' => $result->deliverablecalendarid
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

        $controllers->match('openid', function (Application $app, Request $request) use ($table, $getSchemas){
            $app['session']->start();
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
