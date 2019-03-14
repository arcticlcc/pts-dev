<?php

namespace PTS\Service;

use Silex\Application;
use Silex\ServiceProviderInterface;
use Symfony\Component\HttpFoundation\Request;

/**
 * A service provider for PTS methods.
 *
 * @uses ServiceProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class PTSServiceProvider implements ServiceProviderInterface {

    public $restricted = array(
        'userinfo' => true,
        'login' => true,
    );

    public function register(Application $app) {
        $restricted = $this->restricted;

        $app['put'] = $app->protect(function (Request $request, $class, $id) use ($app, $restricted) {
            $result = array();

            try {
                if (isset($restricted[$class])) {
                    throw new \Exception("Unauthorized.");
                }
            } catch (Exception $exc) {
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

                $response = $app['json']->setAll(null, 409, false, $exc->getMessage())->getResponse();
            }

            $result = $app['saveTable']($request, $class, $id);
            $app['json']->setData($result);
        });

        $app['saveTable'] = $app->protect(function($request, $class, $id = null, $list = false, $strip = array()) use ($app) {
            $result = array();

            try {
                switch ($request->getMethod()) {
                    case 'PUT' :
                        //TODO: exception for no id
                        $object = $app['idiorm']->getTable($class)->find_one($id);
                        break;
                    case 'POST' :
                        $object = $app['idiorm']->getTable($class)->create();
                        break;
                }

                $values = json_decode($request->getContent());

                //don't ever pass the primary key
                $pcol = $object->get_id_column_name();
                unset($values->$pcol);

                foreach ($values as $k => $v) {
                    if (!isset($strip[$k])) {
                        $v = is_string($v) ? trim($v) : $v;
                        $object->set($k, $v);
                    }
                }

                $object->save();

                //see if we want to return the list record or another table
                if ($list) {
                    $tbl = is_string($list) ? $list : $class . 'list';
                    $object = $app['idiorm']->getTable($tbl)->find_one($object->id());
                }

                //$result =
                return $object->as_array();
                //$app['json']->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll($result, $code, $success, $message);
            }
        });

        /**
         *@app mergeRelated
         * Get related data from request and add to the related array
         */
        $app['mergeRelated'] = $app->protect(function(&$related, &$values) use ($app) {
            //get related data from request and add to the related array
            foreach ($related as $k => $v) {
                //var_dump($values);
                if (property_exists($values, $k)) {
                    $related[$k]['values'] = $values->$k;
                } else {
                    //no data to save for this related table
                    //unset($related[$k]);
                }
                unset($values->$k);
                //remove the related data from array
            }
        });

        /**
         * @app saveRelated
         * Saves related tables
         */
        $app['saveRelated'] = $app->protect(function($values, $class, $id = null, $idCol = null, $list = false) use ($app) {
            $result = array();

            if ($id) {
                $object = $app['idiorm']->getTable($class)->find_one($id);
            } else {
                $object = $app['idiorm']->getTable($class)->create();
            }

            foreach ($values as $k => $v) {
                $pcol = $idCol ? $idCol : $class . 'id';
                //don't ever overwrite the primary key
                if ($k != $pcol) {
                    $v = is_string($v) ? trim($v) : $v;
                    $object->set($k, $v);
                }
            }

            $object->save();

            //see if we want to return the list record
            if ($list)
                $object = $app['idiorm']->getTable($class . 'list')->find_one($object->id());

            $result = $object->as_array();
            return $result;
        });

        /**
         * @app saveRelatedTransaction
         * Saves parent and related tables in a single transaction
         * Processes related records marked for deletion
         */
        $app['saveRelatedTransaction'] = $app->protect(function($values, $related, $sql, $pk, $id = false, $filter = null) use ($app) {
            $result = array();

            //need to handle transaction manually to account for errors WRT related data
            $app['db']->transactional(function($conn) use ($app, $values, $related, &$result, $sql, $id, $pk, $filter) {

                //process records to be deleted
                if (property_exists($values, 'destroy')) {
                    //delete related records
                    foreach ($values->destroy as $dClass => $dData) {
                        //get the table name
                        $dTable = $related[$dClass]['name'];
                        //we're assuming the primarykey is {tablename}id
                        $pky = $dTable . 'id';
                        //delete the records
                        foreach ($dData as $obj) {
                            $conn->delete($dTable, array($pky => $obj->id));
                        }
                    }
                    unset($values->destroy);
                    //remove the destroy property
                }

                //check $sql length, if only one word assume it's a tablename
                if (str_word_count($sql) > 1) {
                    $stmt = $conn->prepare($sql);

                    foreach ($values as $k => $v) {
                        $v = is_string($v) ? trim($v) : $v;
                        $stmt->bindValue($k, $v);
                    }

                    if ($id)
                        $stmt->bindValue($pk, $id);
                    $stmt->execute();

                    $result = $stmt->fetch(\PDO::FETCH_ASSOC);
                } else {

                    if ($id) {//check for existing record
                        $object = $app['idiorm']->getTable($sql)->find_one($id);
                    } else {
                        $object = $app['idiorm']->getTable($sql)->create();
                    }

                    foreach ($values as $k => $v) {
                        $v = is_string($v) ? trim($v) : $v;
                        $object->set($k, $v);
                    }

                    $object->save();
                    $result = $object->as_array();
                }

                if (!$id)
                    $id = $result[$pk];

                //save related data
                foreach ($related as $rClass => $rTable) {
                    //we're assuming the primarykey is {tablename}id
                    $pky = $rTable['name'] . 'id';
                    if (isset($rTable['values'])) {
                        foreach ($rTable['values'] as $k => $v) {
                            //set the fkey
                            $v->$pk = $id;
                            //save the related data and add returned data to the result array
                            $app['saveRelated']($v, $rTable['name'], $v->$pky);
                        }
                    }
                    //we return all of the related records, ExtJS associations require this
                    $result[$rClass] = $app['idiorm']->getRelated(true, $rTable['name'], $pk, $id, $filter);

                }

                //return $result;
            });

            return $result;
        });

        $app['getRelated'] = $app->protect(function($request, $class, $key, $id, array $where = null, $format = 'json') use ($app) {
            //if(!$key) $key = $class.'id';

            $page = $request->get('page') ? : $app['page'];
            $start = $request->get('start') ? : $app['start'];
            $limit = $request->get('limit') ? : $app['limit'];
            $sort = $request->get('sort');
            $filter = json_decode($request->get('filter'));
            $result = array();

            try {

                $query = $app['idiorm']->getTable($class)->where($key, $id);

                if ($where) {
                    foreach ($where as $k => $v) {
                        $query->where($k, $v);
                    }
                }

                //create the count query with only filters applied
                $count = clone $app['applyParams']($request, $query, true);

                //add sorting and paging to query
                $app['applyParams']($request, $query, false, true, true);

                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }

                $count = $count->count();

                /*$app['json']->setTotal($count);

                 $app['json']->setData($result);

                 } catch (\Exception $exc) {
                 $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

                 $app['json']->setAll(null, 409, false, $exc->getMessage());
                 }*/

                switch ($format) {
                    case "csv" :
                        $app['csv']->setTitle($class);
                        break;
                    default :
                        $app[$format]->setTotal($count);
                }

                $app[$format]->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

                $app[$format]->setAll(null, 409, false, $exc->getMessage());
            }
        });

        $app['getFirstRelated'] = $app->protect(function($request, $class, $key, $id, array $where = null) use ($app) {
            //if(!$key) $key = $class.'id';

            $page = $request->get('page') ? : $app['page'];
            $start = $request->get('start') ? : $app['start'];
            $limit = $request->get('limit') ? : $app['limit'];
            $sort = $request->get('sort');

            $result = null;

            try {

                $query = $app['idiorm']->getTable($class)->where($key, $id);

                if ($where) {
                    foreach ($where as $k => $v) {
                        $query->where($k, $v);
                    }
                }

                //add sorting to query
                $app['applyParams']($request, $query, false, true, false);

                if ($object = $query->find_one()) {
                    $result = $object->as_array();
                    $app['json']->setData($result);
                } else {
                    $message = "No record found in table '$class' with id of $id.";
                    $success = false;
                    $code = 404;
                    $app['json']->setAll($result, $code, $success, $message);
                }

            } catch (\Exception $exc) {
                $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");

                $app['json']->setAll(null, 409, false, $exc->getMessage());
            }
        });

        /**
         * @app applyParams
         * Applies paging and filter params to a query
         */
        $app['applyParams'] = $app->protect(function(Request $request, $query, $addfilter = FALSE, $addsort = FALSE, $addpage = FALSE) use ($app) {

            $page = $request->query->get('page') ? : $app['page'];
            $start = $request->query->get('start') ? : $app['start'];
            $limit = $request->query->get('limit') ? : $app['limit'];
            $sort = json_decode($request->query->get('sort'));
            $filter = json_decode($request->query->get('filter'));

            if ($addfilter) {
                //add the filters
                if (isset($filter)) {
                    //loop thru filter array
                    foreach ($filter as $val) {
                        $app['addFilter']($query, $val);
                    }
                }
            }

            if ($addsort) {
                //add the sort params
                if (isset($sort)) {
                    //loop thru sort array
                    foreach ($sort as $val) {
                        switch ($val->direction) {
                            case 'ASC' :
                                $query->order_by_asc($val->property);
                                break;
                            case 'DESC' :
                                $query->order_by_desc($val->property);
                                break;
                        }
                    }
                }
            }

            if ($addpage) {
                //add offset and limit
                $query->offset($start)->limit($limit);
            }

            return $query;
        });

        /**
         *@app addFilter
         * Add filter to query
         */
        $app['addFilter'] = $app->protect(function(&$query, $filter) use ($app) {
            //if the filter value is an array test for operator
            //TODO: Implement all Idiorm operators
            if (is_array($filter->value)) {
                switch ($filter->value[0]) {
                    case 'not' :
                        $query->where_not_equal($filter->property, $filter->value[1]);
                        break;
                    case '>' :
                        $query->where_gt($filter->property, $filter->value[1]);
                        break;
                    case '<' :
                        $query->where_lt($filter->property, $filter->value[1]);
                        break;
                    case '<=' :
                        $query->where_lte($filter->property, $filter->value[1]);
                        break;
                    case '>=' :
                        $query->where_gte($filter->property, $filter->value[1]);
                        break;
                    case 'null' :
                        $query->where_null($filter->property);
                        break;
                    case 'not null' :
                        $query->where_not_null($filter->property);
                        break;
                    case 'like' :
                        $query->where_like($filter->property, $filter->value[1]);
                        break;
                    case 'ilike' :
                        $query->where_ilike($filter->property, $filter->value[1] . '%');
                        break;
                    case 'where in' :
                        $query->where_in($filter->property, $filter->value[1]);
                        break;
                    case 'where not in' :
                        $query->where_not_in($filter->property, $filter->value[1]);
                        break;
                    case 'where in array' :
                        $col = $app['db']->quoteIdentifier($filter->property);
                        $query->where_raw("? = ANY({$col})", $filter->value[1]);
                        break;
                    default :
                        throw new \Exception("Invalid filter operator.");
                }
            } else {
                $query->where($filter->property, $filter->value);
            }
        });
    }

    public function boot(Application $app) {
    }

}
?>
