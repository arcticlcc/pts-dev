<?php
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

$app->before(function(Request $request) use ($app) {
    // redirect the user to the login screen if access to the Resource is protected
    $uri_root = parse_url($request->server->get('REQUEST_URI'), PHP_URL_PATH);
    $uri = $request->server->get('REQUEST_URI');

    //check for user, ignore requests to login/logout/openid uri
    if ($uri_root != "/login" && $uri_root != "/logout" && $uri_root != "/openid" && $uri_root != "/oauth2") {

        if('build' !== $app['env']) {
            if(!$app['session']->has('user')) {
                //redirect after login
                return $app->redirect("/login?r=$uri");
            } else {
                //set database search_path
                $schema = $app['session']->get('schema');
                $app['idiorm']->setPath($schema);
            }
        } else {
            //set database search_path
            $app['idiorm']->setPath('dev');
            //set userinfo
            $app['session']->replace(array(
                'user' => array(
                    'loginid' => 1,
                ),
                'schema' => 'dev',
                'schemas' => ['build' => 'Build']
            ));
        }
    }
});

$app->mount('/', new PTS\Controller\PTS());
$app->mount('/', new PTS\Controller\Login());
$app->mount('/', new PTS\Controller\Person());
$app->mount('/', new PTS\Controller\ContactGroup());
$app->mount('/', new PTS\Controller\ProjectContact());
$app->mount('/', new PTS\Controller\ProductContact());
$app->mount('/', new PTS\Controller\Project());
$app->mount('/', new PTS\Controller\Product());
$app->mount('/', new PTS\Controller\Deliverable());
$app->mount('/', new PTS\Controller\Modification());
$app->mount('/', new PTS\Controller\Country());
$app->mount('/', new PTS\Controller\Invoice());
$app->mount('/', new PTS\Controller\Funding());
$app->mount('/', new PTS\Controller\Report());
$app->mount('/', new PTS\Controller\Keyword());
$app->mount('/', new PTS\Controller\Feature());
$app->mount('/', new PTS\Controller\ModStatus());
$app->mount('/', new PTS\Controller\ModDocStatus());
$app->mount('/', new PTS\Controller\UserInfo());
$app->mount('/', new PTS\Controller\Issue());

$app->get('/', function() use ($app) {

    $u = $app['session']->get('user');

    return $app->redirect('/home');

});

$app->get('/home', function() use ($app) {

    $u = $app['session']->get('user');
    $schemas = $app['session']->get('schemas');

    return $app['twig']->render('home.twig', array(
        'name' => $u['firstname'],
        'paths' => $schemas
    ));

});

$app->get('/poll', function() use ($app) {
    //regenerate the sessionid
    $app['session']->migrate(false);

    $u = $app['session']->get('user');
    $json[] = array('success' => true);
    $response = $app['json']->setData($json)->getResponse(true);
    return $response;

});

$app->match('{url}', function($url) use ($app){
    return 'OK';
})->assert('url', '.*')->method('OPTIONS');

//TODO: $request->get() should be $request->query->get() for better performance

//TODO: create method in PTS provider to abstract get requests
$app->get('/{class}.{format}', function(Request $request, $class, $format) use ($app) {

    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if (isset($restricted[$class])) {
            throw new \Exception("Unauthorized.");
        }

        $query = $app['idiorm']->getTable($class);

        //create the count query with only filters applied
        $count = clone $app['applyParams']($request, $query, true);

        //add sorting and paging to query
        $app['applyParams']($request, $query, false, true, true);

        foreach ($query->find_many() as $object) {
            $result[] = $object->as_array();
        }

        switch ($format) {
            case "csv" :
                $app['csv']->setTitle($class);
                break;
            default :
                $app[$format]->setTotal($count->count());
        }

        $response = $app[$format]->setData($result)->getResponse();

    } catch (Exception $exc) {
        $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

        $response = $app[$format]->setAll(null, 409, false, $exc->getMessage())->getResponse();
    }

    return $response;
})->value('format', 'json');

$app->get('/{class}/{id}', function(Request $request, $class, $id) use ($app) {
    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        $u = $app['session']->get('user');

        if (isset($restricted[$class]) && $u['loginid'] != $id) {
            throw new \Exception("Unauthorized Access.");
        }
        $object = $app['idiorm']->getTable($class)->find_one($id);

        if ($object) {
            $result = $object->as_array();
            $app['json']->setData($result);
        } else {
            $message = "No record found in table '$class' with id of $id.";
            $success = false;
            $code = 404;
            $app['json']->setAll($result, $code, $success, $message);
        }
    } catch (Exception $exc) {
        $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
        $message = $exc->getMessage();
        $success = false;
        $code = 400;
        $app['json']->setAll($result, $code, $success, $message);
    }

    return $app['json']->getResponse();
});

$app->get('{class}/{id}/{related}.{format}', function(Request $request, $class, $id, $related, $format) use ($app) {

    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if (isset($restricted[$class])) {
            throw new \Exception("Unauthorized.");
        }
    } catch (Exception $exc) {
        $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())->getResponse();

        return $app['json']->getResponse();
    }

    $app['getRelated']($request, $related, $class . 'id', $id, null, $format);

    return $app[$format]->getResponse();
})->value('format', 'json');

$app->put('/{class}/{id}', function(Request $request, $class, $id) use ($app) {
    $app['put']($request, $class, $id);
    return $app['json']->getResponse();
});

$app->post('/{class}', function(Request $request, $class) use ($app) {
    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if (isset($restricted[$class])) {
            throw new \Exception("Unauthorized.");
        }
    } catch (Exception $exc) {
        $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())->getResponse();

        return $app['json']->getResponse();
    }

    $result = $app['saveTable']($request, $class);
    $app['json']->setData($result);

    return $app['json']->getResponse();
});

$app->delete('/{class}/{id}', function($class, $id) use ($app) {
    $result = array();
    $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    try {
        if (isset($restricted[$class])) {
            throw new \Exception("Unauthorized.");
        }
    } catch (Exception $exc) {
        $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

        $response = $app['json']->setAll(null, 409, false, $exc->getMessage())->getResponse();

        return $app['json']->getResponse();
    }

    try {
        $object = $app['idiorm']->getTable($class)->find_one($id);
        if ($object) {
            $result = $object->as_array();

            $object->delete();
            $app['json']->setData($result);
        } else {
            $message = "No record found in table '$class' with id of $id.";
            $success = false;
            $code = 404;
            $app['json']->setAll($result, $code, $success, $message);
        }
    } catch (Exception $exc) {
        $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
        $message = $exc->getMessage();
        $success = false;
        $code = 400;
        $app['json']->setAll($result, $code, $success, $message);
    }

    return $app['json']->getResponse();
});

?>
