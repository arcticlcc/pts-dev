<?php

use Silex\Application;
use Symfony\Component\HttpFoundation\Response;

// Create the application
$app = new Application();

// Register Silex extensions
//$app->register(new PTS\Service\JSONServiceProvider());
$app->register(new PTS\Service\PTSServiceProvider());
$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__."/../config/reports.yml"));
$app->register(new Silex\Provider\SessionServiceProvider());
$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path'       => __DIR__.'/../views',
    'twig.class_path' => __DIR__.'/../vendor/twig/twig/lib',
));
$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'db.options'            => array(
        'driver'    => 'pdo_pgsql',
        'host'      => 'localhost',
        'dbname'    => 'pts',
        'user'      => 'pts',
        'password'  => '123',
    ),
    'db.dbal.class_path'    => __DIR__.'/../vendor/doctrine/dbal/lib',
    'db.common.class_path'  => __DIR__.'/../vendor/doctrine/common/lib',
));

$app->register(new Silex\Provider\MonologServiceProvider(), array(
    'monolog.logfile'       => __DIR__.'/../log/development.log',
    'monolog.class_path'    => __DIR__.'/../vendor/monolog/monolog/src',
));

$app->register(new Idiorm\IdiormServiceProvider(), array(
    'idiorm.dsn'      => 'pgsql:host=localhost;port=5432;dbname=pts;',
    'idiorm.username' => 'bradley',
    'idiorm.password' => '123'
));

\ORM::configure('id_column_overrides', array(
    'contactgroup' => 'contactid',
    'person' => 'contactid',
    'projectcontactlist' => 'projectcontactid',
    'deliverablelist' => 'deliverableid',
    'userinfo' => 'loginid',
    'membergrouplist' => 'contactcontactgroupid',
    'groupmemberlist' => 'contactcontactgroupid',
    'postalcodelist' => 'postalcode',
    'country' => 'countryiso',
    'personlist' => 'contactid',
    'projectkeywordlist' => 'projectkeywordid'
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
$env = getenv("SILEX_ENV") ? $_ENV['SILEX_ENV'] : 'dev';

if ('dev' == $env) {
    $app['debug'] = true;
    //$app['my.param'] = '...';
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
        return new Response('<h1>Error!</h1>');
    }

});

return $app;
