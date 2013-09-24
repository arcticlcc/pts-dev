<?php
//rand number generator is missing on Windoze
if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    define('Auth_OpenID_RAND_SOURCE', null);
}
//Use Composer, to load additional modules use $loader->add()
$loader = require_once __DIR__.'/../vendor/autoload.php';
?>
