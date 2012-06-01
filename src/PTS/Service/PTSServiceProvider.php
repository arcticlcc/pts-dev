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

class PTSServiceProvider implements ServiceProviderInterface
{
    public function register(Application $app)
    {
        $app['saveTable'] = $app->protect(function ($request, $class, $id = null, $list = false) use ($app) {
                $result = array();

                try {
                    switch ($request->getMethod()) {
                        case 'PUT':
                        //TODO: exception for no id
                            $object = $app['idiorm']->getTable($class)->find_one($id);
                        break;
                        case 'POST':
                            $object = $app['idiorm']->getTable($class)->create();
                        break;
                    }

                    $values = json_decode($request->getContent());

                    foreach ($values as $k => $v)  {
                        $object->set($k, $v);
                    }

                    $object->save();

                    //see if we want to return the list record or another table
                    if($list) {
                        $tbl = is_string($list) ? $list : $class.'list';
                        $object = $app['idiorm']->getTable($tbl)->find_one($object->id());
                    }

                    //$result =
                    return $object->as_array();
                    //$app['json']->setData($result);


                } catch (\Exception $exc) {
                    $app['monolog']->addError($exc->getMessage());
                    $message = $exc->getMessage();
                    $success = false;
                    $code = 400;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            });

        /**
         *@app mergeRelated
         * Get related data from request and add to the related array
         */
        $app['mergeRelated'] = $app->protect(function ($related, $values) use ($app) {
            //get related data from request and add to the related array
            foreach ($related as $k => $v)  {
//var_dump($values);
                if(property_exists($values, $k)) {
                    $related[$k]['values'] = $values->$k;
                }else{
                    //no data to save for this related table
                    //unset($related[$k]);
                }
                unset($values->$k);//remove the related data from array
            }
        });

        /**
         * @app saveRelated
         * Saves related tables
         */
        $app['saveRelated'] = $app->protect(function ($values, $class, $id = null, $idCol = null ,$list = false) use ($app) {
                $result = array();

                try {
                    if($id) {
                            $object = $app['idiorm']->getTable($class)->find_one($id);
                    }else{
                            $object = $app['idiorm']->getTable($class)->create();
                    }

                    foreach ($values as $k => $v)  {
                        $pcol = $idCol ? $idCol : $class.'id';
                        //don't ever overwrite the primary key
                        if($k != $pcol) {
                            $object->set($k, $v);
                        }
                    }

                    $object->save();

                    //see if we want to return the list record
                    if($list) $object = $app['idiorm']->getTable($class.'list')->find_one($object->id());

                    $result = $object->as_array();
                    return $result;


                } catch (\Exception $exc) {
                    $app['monolog']->addError($exc->getMessage());
                    $message = $exc->getMessage();
                    $success = false;
                    $code = 400;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            });

        /**
         * @app saveRelatedTransaction
         * Saves parent and related tables in a single transaction
         */
        $app['saveRelatedTransaction'] = $app->protect(function ($values, $related, $sql, $pk, $id = false, $filter = null) use ($app) {
                $result = array();

                //need to handle transaction manually to account for errors WRT related data
                $app['db']->transactional(function($conn) use ($app, $values, $related, &$result, $sql, $id, $pk, $filter) {
                    //check $sql length, if only one word assume it's a tablename
                    if(str_word_count($sql) > 1) {
                        $stmt = $conn->prepare($sql);

                        foreach ($values as $k => $v)  {
                            $stmt->bindValue($k, $v);
                        }

                        if($id) $stmt->bindValue($pk, $id);
                        $stmt->execute();

                        $result = $stmt->fetch(\PDO::FETCH_ASSOC);
                    } else {

                        if($id) {//check for existing record
                            $object = $app['idiorm']->getTable($sql)->find_one($id);
                        }else {
                            $object = $app['idiorm']->getTable($sql)->create();
                        }

                        foreach ($values as $k => $v)  {
                            $object->set($k, $v);
                        }

                        $object->save();
                        $result = $object->as_array();
                    }

                    if(!$id) $id = $result[$pk];

                    //save related data
                    foreach ($related as $rClass => $rTable)  {
                        //we're assuming the primarykey is {tablename}id
                        $pky = $rTable['name'].'id';
                        if(isset($rTable['values'])) {
                            foreach ($rTable['values'] as $k => $v)  {
                                //set the fkey
                                $v->$pk = $id;
                                //save the related data and add returned data to the result array
                                $app['saveRelated']($v, $rTable['name'], $v->$pky);
                            }
                        }
                        //we return all of the related records, ExtJS associations require this
                        $result[$rClass] = $app['idiorm']->getRelated(true, $rTable['name'], $pk, $id , $filter);

                    }

                    //return $result;
                });

                return $result;
            });

        $app['getRelated'] = $app->protect(function($request, $class, $key, $id, array $where = null) use ($app) {
            //if(!$key) $key = $class.'id';

            $page = $request->get('page') ?: $app['page'];
            $start = $request->get('start') ?: $app['start'];
            $limit = $request->get('limit') ?: $app['limit'];
            $sort = $request->get('sort');

            $result = array();

            try {

                $query = $app['idiorm']->getTable($class)
                            ->where($key, $id);

                if($where) {
                    foreach ($where as $k => $v) {
                        $query->where($k, $v);
                    }
                }

                $count = clone $query;

                if(isset($sort)) {
                    switch ($request->get('dir')) {
                        case 'ASC':
                            $query->order_by_asc($sort);
                            break;
                        case 'DESC':
                            $query->order_by_desc($sort);
                            break;
                    }
                }

                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }

                $count = $count->count();

                $app['json']->setTotal($count);

                $app['json']->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $app['json']->setAll(null, 409, false, $exc->getMessage());
            }
        });

        $app['getFirstRelated'] = $app->protect(function($request, $class, $key, $id, array $where = null) use ($app) {
            //if(!$key) $key = $class.'id';

            $page = $request->get('page') ?: $app['page'];
            $start = $request->get('start') ?: $app['start'];
            $limit = $request->get('limit') ?: $app['limit'];
            $sort = $request->get('sort');

            $result = null;

            try {

                $query = $app['idiorm']->getTable($class)
                            ->where($key, $id);

                if($where) {
                    foreach ($where as $k => $v) {
                        $query->where($k, $v);
                    }
                }

                if(isset($sort)) {
                    switch ($request->get('dir')) {
                        case 'ASC':
                            $query->order_by_asc($sort);
                            break;
                        case 'DESC':
                            $query->order_by_desc($sort);
                            break;
                    }
                }

                if($object = $query->find_one()) {
                    $result = $object->as_array();
                    $app['json']->setData($result);
                }else {
                    $message = "No record found in table '$class' with id of $id.";
                    $success = false;
                    $code = 404;
                    $app['json']->setAll($result,$code,$success,$message);
                }

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $app['json']->setAll(null, 409, false, $exc->getMessage());
            }
        });

        //getable method should implement query and sort
        /*$app['getTable'] = $app->protect(function($request, $class, array $where = null) use ($app) {
            //if(!$key) $key = $class.'id';

            $page = $request->get('page') ?: $app['page'];
            $start = $request->get('start') ?: $app['start'];
            $limit = $request->get('limit') ?: $app['limit'];
            $sort = $request->get('sort');

            $result = array();

            try {

                $query = $app['idiorm']->getTable($class);

                if($where) {
                    foreach ($where as $k => $v) {
                        $query->where($k, $v);
                    }
                }

                $count = clone $query;

                if(isset($sort)) {
                    switch ($request->get('dir')) {
                        case 'ASC':
                            $query->order_by_asc($sort);
                            break;
                        case 'DESC':
                            $query->order_by_desc($sort);
                            break;
                    }
                }

                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }

                $count = $count->count();

                $app['json']->setTotal($count);

                $app['json']->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $app['json']->setAll(null, 409, false, $exc->getMessage());
            }
        });*/
    }
}

?>
