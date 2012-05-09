<?php

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

$app->before(function (Request $request)  use ($app) {
    // redirect the user to the login screen if access to the Resource is protected
    $uri_root = parse_url($request->server->get("REQUEST_URI"),PHP_URL_PATH);
    $uri = $request->server->get("REQUEST_URI");

    //uncomment for building and comment the check below
    /*$app['session']->set('user', array(
        'username' => 'Dev',
        'loginid' => 1,
        'firstname' => 'Dev'
    ));*/

    //check for user, ignore requests to login/logout uri
    if (!$app['session']->has('user') && $uri_root != "/login" && $uri_root != "/logout") {
        //redirect after login
        return $app->redirect("/login?r=$uri");
    }
});

$app->get('/', function() use ($app) {

    //return phpinfo();
    $u = $app['session']->get('user');

    return $app['twig']->render('home.twig', array (
        'name' => $u['firstname']
    ));

});

$app->get('/home', function() use ($app) {

    //return phpinfo();
    $u = $app['session']->get('user');

    return $app['twig']->render('home.twig', array (
        'name' => $u['firstname']
    ));

});

$app->get('/poll', function() use ($app) {

    $u = $app['session']->get('user');
    $json[] = array('success'=>true);
    $response = $app['json']->setData($json)
                ->getResponse(true);
    return $response;

});

//TODO: $request->get() should be $request->request->get() for better performance

//TODO: create method in PTS provider to abstract get requests
$app->get('/{class}', function (Request $request, $class) use ($app) {
    $page = $request->get('page') ?: $app['page'];
    $start = $request->get('start') ?: $app['start'];
    $limit = $request->get('limit') ?: $app['limit'];
    $sort = json_decode($request->get('sort'));

    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if(isset($restricted[$class])) {
            throw new Exception("Unauthorized.");
        }

        $query = $app['idiorm']->getTable($class)
                ->offset($start)
                ->limit($limit);

        if (isset($sort)) {
            //loop thru sort array
            foreach($sort as $val) {
                switch ($val->direction) {
                    case 'ASC':
                        $query->order_by_asc($val->property);
                        break;
                    case 'DESC':
                        $query->order_by_desc($val->property);
                        break;
                }
            }
        }

        foreach ($query->find_many() as $object) {
            $result[] = $object->as_array();
        }

        $app['json']->setTotal($app['idiorm']->getTable($class)->count());

        $response = $app['json']->setData($result)
                    ->getResponse();

    } catch (Exception $exc) {
        $app['monolog']->addError($exc->getMessage());

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())
                    ->getResponse();
    }

    return $response;
});

$app->get('/{class}/{id}', function (Request $request, $class, $id) use ($app) {
    $result = array();

    try {
        $object = $app['idiorm']->getTable($class)
                  ->find_one($id);

        if($object) {
            $result = $object->as_array();
            $app['json']->setData($result);
        }else {
            $message = "No record found in table '$class' with id of $id.";
            $success = false;
            $code = 404;
            $app['json']->setAll($result,$code,$success,$message);
        }
    } catch (Exception $exc) {
        $app['monolog']->addError($exc->getMessage());
        $message = $exc->getMessage();
        $success = false;
        $code = 400;
        $app['json']->setAll($result,$code,$success,$message);
    }

    return $app['json']->getResponse();
});

$app->get('{class}/{id}/{related}', function (Request $request, $class, $id, $related) use ($app) {

    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if(isset($restricted[$class])) {
            throw new Exception("Unauthorized.");
        }
    } catch (Exception $exc) {
        $app['monolog']->addError($exc->getMessage());

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())
                    ->getResponse();

        return $app['json']->getResponse();
    }

    $app['getRelated']($request, $related, $class .'id', $id);

    return $app['json']->getResponse();
});

$app->put('/{class}/{id}', function (Request $request, $class, $id) use ($app) {
    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if(isset($restricted[$class])) {
            throw new Exception("Unauthorized.");
        }
    } catch (Exception $exc) {
        $app['monolog']->addError($exc->getMessage());

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())
                    ->getResponse();

        return $app['json']->getResponse();
    }

    $result = $app['saveTable']($request, $class, $id);
    $app['json']->setData($result);

    return $app['json']->getResponse();
});

$app->post('/{class}', function (Request $request, $class) use ($app) {
    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if(isset($restricted[$class])) {
            throw new Exception("Unauthorized.");
        }
    } catch (Exception $exc) {
        $app['monolog']->addError($exc->getMessage());

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())
                    ->getResponse();

        return $app['json']->getResponse();
    }

    $result = $app['saveTable']($request, $class);
    $app['json']->setData($result);

    return $app['json']->getResponse();
});

$app->delete('/{class}/{id}', function ($class, $id) use ($app) {
    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if(isset($restricted[$class])) {
            throw new Exception("Unauthorized.");
        }
    } catch (Exception $exc) {
        $app['monolog']->addError($exc->getMessage());

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())
                    ->getResponse();

        return $app['json']->getResponse();
    }

    try {
        $object = $app['idiorm']->getTable($class)->find_one($id);
        if($object) {
            $result = $object->as_array();

            $object->delete();
            $app['json']->setData($result);
        }else {
            $message = "No record found in table '$class' with id of $id.";
            $success = false;
            $code = 404;
            $app['json']->setAll($result,$code,$success,$message);
        }
    } catch (Exception $exc) {
        $app['monolog']->addError($exc->getMessage());
        $message = $exc->getMessage();
        $success = false;
        $code = 400;
        $app['json']->setAll($result,$code,$success,$message);
    }

    return $app['json']->getResponse();
});

$app->mount('/', new PTS\Controller\PTS());
$app->mount('/', new PTS\Controller\Login());
$app->mount('/', new PTS\Controller\Person());
$app->mount('/', new PTS\Controller\ContactGroup());
$app->mount('/', new PTS\Controller\ProjectContact());
$app->mount('/', new PTS\Controller\Project());
$app->mount('/', new PTS\Controller\Deliverable());
$app->mount('/', new PTS\Controller\Modification());
$app->mount('/', new PTS\Controller\Country());
$app->mount('/', new PTS\Controller\Invoice());
$app->mount('/', new PTS\Controller\Funding());
?>
