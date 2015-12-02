<?php

use Silex\Application;
use Silex\Provider;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Debug\ErrorHandler;
use Symfony\Component\HttpKernel\Debug\ExceptionHandler;

// Create the application
$app = new Application();
//set directory for config files
$app['config.dir'] = __DIR__.'/../config/';

// Register Silex extensions
//$app->register(new PTS\Service\JSONServiceProvider());
$app->register(new PTS\Service\PTSServiceProvider());
$app->register(new PTS\Controller\Feature());
$app->register(new Igorw\Silex\ConfigServiceProvider($app['config.dir'] . "reports.yml"));
$app->register(new Igorw\Silex\ConfigServiceProvider($app['config.dir'] . "db.yml"));
$app->register(new Igorw\Silex\ConfigServiceProvider($app['config.dir'] . "google.yml", array(
    'config_path' => $app['config.dir'],
)));
$app->register(new Silex\Provider\SessionServiceProvider(), array(
    'session.storage.save_path' => __DIR__.'/../sessions'
));
$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path'       => __DIR__.'/../views',
    'twig.class_path' => __DIR__.'/../vendor/twig/twig/lib',
));
$app->register(new SilexMarkdown\MarkdownExtension(), array());

//use the wrapper class to support Idiorm + DBAL
$dbsOptions = $app['dbOptions'];
foreach ($dbsOptions as $opt => $vals) {
    $dbsOptions[$opt]['wrapperClass'] = 'Idiorm\ExtendedConnection';
}

$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'dbs.options'           => $dbsOptions,
    'db.dbal.class_path'    => __DIR__.'/../vendor/doctrine/dbal/lib',
    'db.common.class_path'  => __DIR__.'/../vendor/doctrine/common/lib',
));

$app->register(new Silex\Provider\MonologServiceProvider(), array(
    'monolog.logfile'           => __DIR__.'/../log/development.log',
    'monolog.console_logfile'   => __DIR__.'/../log/console.log',
    'monolog.class_path'        => __DIR__.'/../vendor/monolog/monolog/src',
));

$app->register(new Idiorm\IdiormServiceProvider(), array());
$app->register(new PTS\Service\GoogleServiceProvider(), array());
$app->register(new Aws\Silex\AwsServiceProvider(), array(
    'aws.config' => $app['config.dir'] . 'aws.json'
));
$app->register(new PTS\Service\AwsEmailServiceProvider(), array(
    'ses.limit' => 1,
));
$app->register(new PTS\Service\NoticeServiceProvider(), array());

$app->register(new PTS\Service\OpenIDServiceProvider(), array(
    'openid.uri'      => 'https://www.google.com/accounts/o8/id',
    'openid.attribute'=> array(
        // Usage: make($type_uri, $count=1, $required=false, $alias=null)
        \Auth_OpenID_AX_AttrInfo::make('http://axschema.org/contact/email',1,1, 'email'),
        \Auth_OpenID_AX_AttrInfo::make('http://axschema.org/namePerson/first',1,1, 'firstname'),
        \Auth_OpenID_AX_AttrInfo::make('http://axschema.org/namePerson/last',1,1, 'lastname'),
    )
));

$app->register(new Knp\Provider\ConsoleServiceProvider(),
    array(
        'console.name' => 'PTSConsole',
        'console.version' => '0.1.0',
        'console.project_directory' => __DIR__ . "/.."
    )
);

Idiorm\PTSORM::configure('id_column_overrides', array(
    'contactgroup' => 'contactid',
    'person' => 'contactid',
    'projectcontactlist' => 'projectcontactid',
    'productcontactlist' => 'productcontactid',
    'deliverablelist' => 'deliverableid',
    'deliverabledue' => 'deliverableid',
    'deliverablereminder' => 'deliverableid',
    'userinfo' => 'loginid',
    'membergrouplist' => 'contactcontactgroupid',
    'groupmemberlist' => 'contactcontactgroupid',
    'postalcodelist' => 'postalcode',
    'country' => 'countryiso',
    'personlist' => 'contactid',
    'projectkeywordlist' => 'projectkeywordid',
    'projectfeature' => 'id',
    'productfeature' => 'id',
    'modstatuslist' => 'modstatusid',
    'moddocstatuslist' => 'moddocstatusid',
    'modificationlist' => 'modificationid',
    'metadataproject' => 'projectid',
    'metadataproduct' => 'productid',
    'projectmetadata' => 'projectid',
    'productmetadata' => 'productid',
    'productlist' => 'productid',
    'productkeywordlist' => 'productkeywordid',
    'modificationcontact' => array(
        'modification' => 'modificationid',
        'projectcontact' => 'projectcontactid'
    ),
    'modificationcontactlist' => 'modificationid',
    //TODO: fix these to use compound keys after Idiorm upgrade
    'producttopiccategory' => 'productid',
    'productspatialformat' => 'productid',
    'productepsg' => 'productid',
    'productwkt' => 'productid',
    'projectprojectcategory' => 'projectid',
    'projectusertype' => 'projectid',
    'projecttopiccategory' => 'projectid',
));

// Add services to the DI container
//$app['my.service'] = function() {
//    // ...
//    return new My\Service();
//};
$app['json'] = $app->share(function() {

    return new PTS\Service\JSON();
});

$app['adiwg'] = $app->share(function($app) {

    return new PTS\Service\ADIwg($app);
});

$app['twig'] = $app->share($app->extend('twig', function($twig, $app) {
    //$json = $app["json"]->encode;
    $twig->getExtension('core')->setEscaper('json', array('PTS\Service\JSON', 'encode'));
    return $twig;
}));

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
$app['baseURL'] = '..';
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
    $app['my.profiler'] = preg_match('/^\/_profiler.*/', $_SERVER["REQUEST_URI"]) === 1;

    $app->register(new Silex\Provider\ServiceControllerServiceProvider());
    $app->register(new Silex\Provider\UrlGeneratorServiceProvider());
    $app->register(new Silex\Provider\HttpFragmentServiceProvider());
    $app->register(new Silex\Provider\WebProfilerServiceProvider(), array(
        'profiler.cache_dir' => __DIR__.'/../tmp/cache/profiler',
        'profiler.mount_prefix' => '/_profiler', // this is the default
    ));

    $app->register(new Silex\Provider\DebugServiceProvider, array(
        'debug.max_items' => 250, // this is the default
        'debug.max_string_length' => -1, // this is the default
    ));
}

ErrorHandler::register();
if ('cli' !== php_sapi_name()) {
    ExceptionHandler::register();
}

// Error handling
$app->error(function (\Exception $ex, $code) use ($app) {
    $json = $app["request"]->server->get('HTTP_ACCEPT') == 'application/json';

    if ($app['debug']) {
        return;
    }

    if($json) {
        $app['monolog']->addError($ex->getMessage());
         return $response = $app['json']->setAll(null, $code, false, "Sorry, there was an error. It's been logged and we'll look into it.")->getResponse();
    } else {
        if (404 == $code) {
            return new Response(file_get_contents(__DIR__.'/../web/404.html'));
        } else {
            // Do something more sophisticated here (logging etc.)
            return new Response(file_get_contents(__DIR__.'/../web/500.html'));
            //return new Response('<h1>Error!</h1>');
        }
    }
});

return $app;
