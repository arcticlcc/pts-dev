<?php

require_once __DIR__.'/../src/autoload.php';

$app = require __DIR__.'/../src/bootstrap.php';

if(!isset($app['my.profiler']) || !$app['my.profiler']) {
    require __DIR__.'/../src/app.php';
}

$app->run();
