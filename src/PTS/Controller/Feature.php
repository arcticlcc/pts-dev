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
            try{
                $result = array();
                $projectid = $request->get('projectid');
                $query = $app['idiorm']->getTable('projectfeature');

                if($projectid) {
                    $query->where('projectid', $projectid);
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

        $controllers->post('projectfeature', function (Application $app, Request $request) use ($types) {
            try {
                $json = json_decode($request->getContent());
                $result = array();

                //need to wrap everything in a transaction
                $app['db']->transactional(function($conn) use ($app, $json, $types, &$result) {
                        foreach($json->features as $feature) {
                            $geom = $feature->geometry;
                            $values = $feature->properties;
                            $values->wkt = $app['toWKT']($geom);
                            unset($values->fid);
                            $table = $types[$geom->type];

                            $sql = "INSERT INTO " . $table . "
                                (projectid, name, comment,the_geom)
                                VALUES (:projectid, :name, :comment, ST_GeomFromText(:wkt,3857))
                            RETURNING '" . $geom->type . "-'|| " . $table . "id AS id, projectid,
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

        $controllers->put('projectfeature/{id}', function (Application $app, Request $request, $id) use ($types) {
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
                    SET projectid=:projectid, name=:name, comment=:comment,
                        the_geom = ST_GeomFromText(:wkt,3857)
                    WHERE " . $table . "id = :id
                RETURNING '" . $geom->type . "-'|| " . $table . "id AS id, projectid,
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

        //this is the delete method, openlayers only passes the feature data
        // when using post to delete and we wnat to check the geometry for the
        //type instead of relying on the id passed in the url
        $controllers->post('projectfeature/{id}', function (Application $app, Request $request, $id) use ($types) {
            try {
                $feature = json_decode($request->getContent());
                $geom = $feature->geometry;
                $id = explode('-',$id);
                $table = $types[$geom->type];
                $result = array();

                $object = $app['idiorm']->getTable($table)->find_one($id[1]);

                if($object) {
                    //we'll actually return from the projectfeature view
                    $return = $app['idiorm']->getTable('projectfeature')->find_one($geom->type .'-' . $id[1]);
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
        return $controllers;
    }
}

?>
