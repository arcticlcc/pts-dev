<?php

namespace Idiorm;

require_once __DIR__.'/../../vendor/Idiorm/idiorm.php';

use Silex\Application;
use Silex\ServiceProviderInterface;

class IdiormServiceProvider implements ServiceProviderInterface
{
    public function register(Application $app)
    {
        $app['idiorm'] = $app->share(function () use ($app) {
			\ORM::set_db($app['db']); //use dbal pdo instance
            /*\ORM::configure($app['idiorm.dsn']);
            \ORM::configure('username', $app['idiorm.username']);
            \ORM::configure('password', $app['idiorm.password']);
            \ORM::configure('driver_options', array(
                \PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
            ));*/

            return new IdiormWrapper($app);
        });
    }
}

class IdiormWrapper
//TODO: create PTS provider containing methods with responses
{
    protected $app;

    public function __construct(Application $app)
    {
        $this->app = $app;
    }

    public function getTable($tableName)
    {
        return \ORM::for_table($tableName);
    }

    public function getDb()
    {
        return \ORM::get_db();
    }

    public function getRelated($array, $class, $key, $id, array $where = null, $sort = null, $dir = null)
    {

            $query = $this->app['idiorm']->getTable($class)
                        ->where($key, $id);

            if($where) {
                foreach ($where as $k => $v) {
                    if(is_array($v)) {
                        $query->where_in($k, $v);
                    }else {
                        $query->where($k, $v);
                    }
                }
            }

            if(isset($sort)) {
                switch ($dir) {
                    case 'DESC':
                        $query->order_by_desc($sort);
                        break;
                    default:
                        $query->order_by_asc($sort);
                }
            }

            if($array) {
                $result = array();
                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }
            }else {
                $result = $query->find_many();
            }

            return($result);

    }
}
