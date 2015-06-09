<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ServiceProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

use Geokit\Geometry\Transformer\WKTTransformer;
use Geokit\Geometry\GeometryCollection;
use Geokit\Geometry\LineString;
use Geokit\Geometry\LinearRing;
use Geokit\Geometry\MultiLineString;
use Geokit\Geometry\MultiPoint;
use Geokit\Geometry\MultiPolygon;
use Geokit\Geometry\Point;
use Geokit\Geometry\Polygon;

/**
 * Controller for project vector features.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Feature implements ControllerProviderInterface, ServiceProviderInterface
{
    public function register(Application $app)
    {
        /**
         * Simple function that takes php decoded GeoJSON geometry
         * object (Point,LineString,or Polygon) and converts to WKT
         * suitable for use in a sql statment for insertion into PostGIS
         * table. Does NOT support "multi" geometries.
         */
        $app['toWKT'] = $app->protect(function ($geom) use ($app) {
            $points = array();

            switch($geom->type) {
                case 'Polygon':
                    foreach($geom->coordinates[0] as $val) {
                        $points[] = new Point($val[0],$val[1]);
                    }
                    $ring = new LinearRing($points);
                    $geom = new Polygon(array($ring));
                    break;

                case 'LineString':
                    foreach($geom->coordinates as $val) {
                        $points[] = new Point($val[0],$val[1]);
                    }
                    $geom = new LineString($points);
                    break;

                case 'Point':
                    $geom = new Point($geom->coordinates[0],$geom->coordinates[1]);
                    break;

                default:
                    throw new \Exception(sprintf('"%s" is not a valid geometry type.',$feature->geometry->type));
            }

            $transformer = new WKTTransformer(true);
            return $transformer->transform($geom);
        });

        /**
         * Takes array of ORM associative arrays and constructs
         * GeoJSON featurecollection. Expects GeoJSON encoded geometry
         * object to be included with each record in the array.
         */
        $app['toGeoJSON'] = $app->protect(function (array $result, $idCol = 'id', $geomCol = 'geom') use ($app) {
            $geoJSON = '{"type":"FeatureCollection","features":';
            $features = array();

            foreach($result as $feature) {
                $j['type'] = 'Feature';
                $j['id'] = $feature[$idCol];
                unset($feature[$idCol]);
                $j['geometry'] = json_decode($feature[$geomCol]);
                unset($feature[$geomCol]);
                //assign the rest of the values as propoerties
                $j['properties'] = $feature;
                $features[] = $j;
            }

            $geoJSON .= json_encode($features) . '}';

            return $geoJSON;
        });

        /**
         * Get a feature.
         */
        $app['getFeature'] = $app->protect(function (Request $request, $class) use ($app) {
            $idCol = $class . 'id';
            $table = $class . 'feature';

            try{
                $result = array();
                $id = $request->get($idCol);
                $query = $app['idiorm']->getTable($table);

                if($id) {
                    $query->where($idCol, $id);
                }

                foreach ($query->find_many() as $object) {
                    $result[] = $object->as_array();
                }

                $geoJSON = $app['toGeoJSON']($result);
                return new Response($geoJSON, 200, array(
                    'Content-type' => 'application/json'
                ));

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
            }
        });

        /**
         * Create a feature.
         */
        $app['createFeature'] = $app->protect(function (Request $request, $class, array $types) use ($app) {
            $idCol = $class . 'id';

            try {
                $json = json_decode($request->getContent());
                $result = array();

                //need to wrap everything in a transaction
                $app['db']->transactional(function($conn) use ($app, $json, $types, &$result, $idCol) {
                        foreach($json->features as $feature) {
                            $geom = $feature->geometry;
                            $values = $feature->properties;
                            $values->wkt = $app['toWKT']($geom);
                            unset($values->fid);
                            $table = $types[$geom->type];

                            $sql = "INSERT INTO " . $table . "
                                ($idCol, name, comment,the_geom)
                                VALUES (:$idCol, :name, :comment, ST_GeomFromText(:wkt,3857))
                            RETURNING '" . $geom->type . "-'|| " . $table . "id AS id, $idCol,
                            name, comment,ST_AsGeoJSON(the_geom) AS geom";

                            $stmt = $conn->prepare($sql);

                            foreach ($values as $k => $v)  {
                                //TODO: Add PDO type check to other bind statements
                                $stmt->bindValue($k, $v,$app['util']->getPDOConstantType($v));
                            }

                            $stmt->execute();
                            $result[] = $stmt->fetch(\PDO::FETCH_ASSOC);
                        }
                    });

                    $geoJSON = $app['toGeoJSON']($result);
                    return new Response($geoJSON, 200, array(
                        'Content-type' => 'application/json'
                    ));

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
                return $app['json']->getResponse();
            }
        });

        /**
         * Update a feature.
         */
        $app['updateFeature'] = $app->protect(function (Request $request, $id, $class, array $types) use ($app) {
            $idCol = $class . 'id';

            try {
                $feature = json_decode($request->getContent());
                $geom = $feature->geometry;
                $values = $feature->properties;
                $values->wkt = $app['toWKT']($geom);
                unset($values->fid);
                $id = explode('-',$id);
                $values->id = $id[1];
                $table = $types[$geom->type];
                $result = array();

                $sql = "UPDATE " . $table . "
                    SET $idCol=:$idCol, name=:name, comment=:comment,
                        the_geom = ST_GeomFromText(:wkt,3857)
                    WHERE " . $table . "id = :id
                RETURNING '" . $geom->type . "-'|| " . $table . "id AS id, $idCol,
                name, comment,ST_AsGeoJSON(the_geom) AS geom";

                $stmt = $app['db']->prepare($sql);

                foreach ($values as $k => $v)  {
                    //TODO: Add PDO type check to other bind statements
                    $stmt->bindValue($k, $v,$app['util']->getPDOConstantType($v));
                }

                $stmt->execute();
                $result[] = $stmt->fetch(\PDO::FETCH_ASSOC);


                $geoJSON = $app['toGeoJSON']($result);
                return new Response($geoJSON, 200, array(
                    'Content-type' => 'application/json'
                ));

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
                return $app['json']->getResponse();
            }
        });

        /**
         * Delete a feature.
         */
        $app['deleteFeature'] = $app->protect(function (Request $request, $id, $class, array $types) use ($app) {
            $tab = $class . 'feature';

            try {
                $feature = json_decode($request->getContent());
                $geom = $feature->geometry;
                $id = explode('-',$id);
                $table = $types[$geom->type];
                $result = array();

                $object = $app['idiorm']->getTable($table)->find_one($id[1]);

                if($object) {
                    //we'll actually return from the {$class}feature view
                    $return = $app['idiorm']->getTable($tab)->find_one($geom->type .'-' . $id[1]);
                    $result[] = $return->as_array();
                    //delete the object
                    $object->delete();

                    $geoJSON = $app['toGeoJSON']($result);
                    return new Response($geoJSON, 200, array(
                        'Content-type' => 'application/json'
                    ));

                }else {
                    $message = "No record found in table '$table' with id of $id[1].";
                    $success = false;
                    $code = 404;
                    $app['json']->setAll($result,$code,$success,$message);
                }
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $message = $exc->getMessage();
                $success = false;
                $code = 400;
                $app['json']->setAll(null,$code,$success,$message);
            }

            return $app['json']->getResponse();
        });
    }

    public function boot(Application $app)
    {
    }

    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $types = array(
            'Polygon' => 'projectpolygon',
            'LineString' => 'projectline',
            'Point' => 'projectpoint'
        );

        $controllers->get('projectfeature', function (Application $app, Request $request) {
            return $app['getFeature']($request, 'project');
        });

        $controllers->post('projectfeature', function (Application $app, Request $request) use ($types) {
            return $app['createFeature']($request, 'project', $types);
        });

        $controllers->put('projectfeature/{id}', function (Application $app, Request $request, $id) use ($types) {
            return $app['updateFeature']($request, $id, 'project', $types);
        });

        //this is the delete method, openlayers only passes the feature data
        // when using post to delete and we want to check the geometry for the
        //type instead of relying on the id passed in the url
        $controllers->post('projectfeature/{id}', function (Application $app, Request $request, $id) use ($types) {
            return $app['deleteFeature']($request, $id, 'project', $types);
        });

        $ptypes = array(
            'Polygon' => 'productpolygon',
            'LineString' => 'productline',
            'Point' => 'productpoint'
        );

        $controllers->get('productfeature', function (Application $app, Request $request) {
            return $app['getFeature']($request, 'product');
        });

        $controllers->post('productfeature', function (Application $app, Request $request) use ($ptypes) {
            return $app['createFeature']($request, 'product', $types);
        });

        $controllers->put('productfeature/{id}', function (Application $app, Request $request, $id) use ($ptypes) {
            return $app['updateFeature']($request, $id, 'product', $types);
        });

        //this is the delete method, openlayers only passes the feature data
        // when using post to delete and we want to check the geometry for the
        //type instead of relying on the id passed in the url
        $controllers->post('productfeature/{id}', function (Application $app, Request $request, $id) use ($ptypes) {
            return $app['deleteFeature']($request, $id, 'product', $types);
        });
        return $controllers;
    }
}

?>
