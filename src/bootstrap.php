<?php

use Silex\Application;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Debug\ErrorHandler;
use Symfony\Component\HttpKernel\Debug\ExceptionHandler;

// Create the application
$app = new Application();

// Register Silex extensions
//$app->register(new PTS\Service\JSONServiceProvider());
$app->register(new PTS\Service\PTSServiceProvider());
$app->register(new PTS\Controller\Feature());
$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__."/../config/reports.yml"));
$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__."/../config/db.yml"));
$app->register(new Silex\Provider\SessionServiceProvider(), array(
    'session.storage.save_path' => __DIR__.'/../sessions'
));
$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path'       => __DIR__.'/../views',
    'twig.class_path' => __DIR__.'/../vendor/twig/twig/lib',
));
$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'db.options'            => $app['dbOptions'],
    'db.dbal.class_path'    => __DIR__.'/../vendor/doctrine/dbal/lib',
    'db.common.class_path'  => __DIR__.'/../vendor/doctrine/common/lib',
));

$app->register(new Silex\Provider\MonologServiceProvider(), array(
    'monolog.logfile'       => __DIR__.'/../log/development.log',
    'monolog.class_path'    => __DIR__.'/../vendor/monolog/monolog/src',
));

$app->register(new Idiorm\IdiormServiceProvider(), array());

$app->register(new PTS\Service\GcalServiceProvider(), array(
    'gcal.service_account'      => '446561781403-4k46rnbg48b6e0o963qqkcc83li40ffm@developer.gserviceaccount.com',
    'gcal.key' => __DIR__.'/../config/client.p12',
));

$app->register(new PTS\Service\OpenIDServiceProvider(), array(
    'openid.uri'      => 'https://www.google.com/accounts/o8/id',
    'openid.attribute'=> array(
        // Usage: make($type_uri, $count=1, $required=false, $alias=null)
        \Auth_OpenID_AX_AttrInfo::make('http://axschema.org/contact/email',1,1, 'email'),
        \Auth_OpenID_AX_AttrInfo::make('http://axschema.org/namePerson/first',1,1, 'firstname'),
        \Auth_OpenID_AX_AttrInfo::make('http://axschema.org/namePerson/last',1,1, 'lastname'),
    )
));

Idiorm\PTSORM::configure('id_column_overrides', array(
    'contactgroup' => 'contactid',
    'person' => 'contactid',
    'projectcontactlist' => 'projectcontactid',
    'deliverablelist' => 'deliverableid',
    'deliverabledue' => 'deliverableid',
    'userinfo' => 'loginid',
    'membergrouplist' => 'contactcontactgroupid',
    'groupmemberlist' => 'contactcontactgroupid',
    'postalcodelist' => 'postalcode',
    'country' => 'countryiso',
    'personlist' => 'contactid',
    'projectkeywordlist' => 'projectkeywordid',
    'projectfeature' => 'id',
    'modstatuslist' => 'modstatusid',
    'moddocstatuslist' => 'moddocstatusid',
    'modificationlist' => 'modificationid'
));

// Add services to the DI container
//$app['my.service'] = function() {
//    // ...
//    return new My\Service();
//};
$app['json'] = $app->share(function() {

    return new PTS\Service\JSON();
});

$app['csv'] = $app->share(function() {

    return new PTS\Service\CSV();
});

$app['util'] = $app->share(function() {

    return new PTS\Service\Util();
});

$app['tree'] = $app->share(function() {

    return new PTS\Service\Tree();
});

// Configuration parameters
$app['salt'] = 'PTS2012';
$app['debug'] = false;
//query defaults
$app['page'] = 1;
$app['start'] = 0;
$app['limit'] = 1000;
//$app['my.param'] = '...';

// Override settings for your dev environment
$env = getenv("SILEX_ENV") ? $_SERVER['SILEX_ENV'] : 'dev';

if ('dev' == $env) {
    $app['debug'] = TRUE;
    //$app['my.param'] = '...';
}

ErrorHandler::register();
if ('cli' !== php_sapi_name()) {
    ExceptionHandler::register();
}

// Error handling
$app->error(function (\Exception $ex, $code) use ($app) {

    if ($app['debug']) {
        return;
    }

    if (404 == $code) {
        return new Response(file_get_contents(__DIR__.'/../web/404.html'));
    } else {
        // Do something more sophisticated here (logging etc.)
        return new Response(file_get_contents(__DIR__.'/../web/500.html'));
        //return new Response('<h1>Error!</h1>');
    }

});

return $app;
