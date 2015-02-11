<?php

namespace Idiorm;

require_once __DIR__ . '/../../vendor/Idiorm/idiorm.php';
//require_once __DIR__ . '/../../vendor/j4mie/idiorm/idiorm.php';

use Silex\Application;
use Silex\ServiceProviderInterface;

class PTSORM extends \ORM {
    /*function __construct($table_name, $data = array()) {
     parent::__construct($table_name, $data = array());
     }*/

    // The
    protected $_subquery;

    /**
     * Identify whether a subquery is used for the table source
     */
    public function subquery() {
        $this->_subquery = TRUE;
        return $this;
    }

    public static function for_table($table_name) {
        self::_setup_db();
        return new self($table_name);
    }

    /**
     * Build the start of the SELECT statement
     */
    public function _build_select_start() {
        $result_columns = join(', ', $this->_result_columns);

        if ($this->_distinct) {
            $result_columns = 'DISTINCT ' . $result_columns;
        }

        $table = $this->_subquery ? $this->_table_name : $this->_quote_identifier($this->_table_name);
        $fragment = "SELECT {$result_columns} FROM " . $table;

        if (!is_null($this->_table_alias)) {
            $fragment .= " " . $this->_quote_identifier($this->_table_alias);
        }
        return $fragment;
    }

}

class IdiormServiceProvider implements ServiceProviderInterface {
    public function register(Application $app) {
        $app['idiorm'] = $app->share(function() use ($app) {
            PTSORM::set_db($app['db']);
            //use dbal pdo instance
            /*\ORM::configure($app['idiorm.dsn']);
             \ORM::configure('username', $app['idiorm.username']);
             \ORM::configure('password', $app['idiorm.password']);
             \ORM::configure('driver_options', array(
             \PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
             ));*/

            return new IdiormWrapper($app);
        });
    }

    public function boot(Application $app) {
    }

}

class IdiormWrapper
//TODO: create PTS provider containing methods with responses
{
    protected $app;
    protected $schema;

    public function __construct(Application $app) {
        $this->app = $app;
    }

    public function setPath($schema) {
        $sql = "SET search_path=common, $schema, cvl, gcmd, public;";
//echo $sql;
        $stmt = $this->getDb()->prepare($sql);
        $stmt->execute();
        $this->schema = $schema;
    }

    public function getSchema() {
        return $this->schema;
    }

    public function getTable($tableName) {
        return PTSORM::for_table($tableName);
    }

    public function getDb() {
        return PTSORM::get_db();
    }

    public function getRelated($array, $class, $key, $id, array $where = null, $sort = null, $dir = null, $limit = null) {

        $query = $this->app['idiorm']->getTable($class)->where($key, $id);

        if ($where) {
            foreach ($where as $k => $v) {
                if (is_array($v)) {
                    $query->where_in($k, $v);
                } else {
                    $query->where($k, $v);
                }
            }
        }

        if (isset($sort)) {
            switch ($dir) {
                case 'DESC' :
                    $query->order_by_desc($sort);
                    break;
                default :
                    $query->order_by_asc($sort);
            }
        }

        if (isset($limit)) {
            $query->limit($limit);
        }

        if ($array) {
            $result = array();
            foreach ($query->find_many() as $object) {
                $result[] = $object->as_array();
            }
        } else {
            $result = $query->find_many();
        }

        return ($result);

    }

    public function getFirstRelated($array, $class, $key, $id, array $where = null, $sort = null, $dir = null) {
        $args = func_get_args();
        array_push($args, 1);

        $result = call_user_func_array(array('Idiorm\IdiormWrapper','getRelated'), $args);

        if($result) {
            return array($result[0]);
        } else {
            return $result;
        }
    }

}
