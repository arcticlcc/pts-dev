<?php

namespace PTS\Service;

/**
 * Generate and publish ADIwg metadata.
 *
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class ADIwg {

    private $app;

    public function __construct($app) {
        $this->app = $app;
    }

    function getGroupScienceBaseId($schema = false) {
      $schema = $schema ? $schema : $this->app['session']->get('schema');

      $group = $this->app['idiorm']
          ->getTable('groupschema')
          ->select('sciencebaseid')
          ->where('groupschemaid', $schema)
          ->find_one();

      return $group->sciencebaseid;
    }

    function getProject($id, $withAssoc = false) {
        $contacts = array();
        $roles = array();

        $pquery = $this->app['idiorm']->getTable('metadataproject')->select('metadataproject.*');

        if (strpos($id, '-') === FALSE) {
            $probject = $pquery->where("projectid", $id)->find_one();
        } else {
            $probject = $pquery->where("projectcode", $id)->find_one();
        }

        if ($probject) {
            $project = $probject->as_array();
        } else {
            throw new \Exception("Couldn't find a project with id = $id.");
        };

        //get LCC contact
        $org = $this->app['idiorm']->getTable('metadatacontact')->where('contactId', $project['orgid'])->find_one()->as_array();

        $contacts[] = $org;

        //get other contacts for project
        foreach ($this->app['idiorm']->getTable('metadatacontact')->distinct()->select('metadatacontact.*')
        ->join('projectallcontacts', array('metadatacontact.contactId', '=', 'projectallcontacts.contactid'))
        -> where('projectallcontacts.projectid', $project['projectid'])
        -> where_not_equal('contactId', $org['contactId'])
        ->find_many() as $object) {
            $contacts[] = $object->as_array();
        }
//dump($contacts);
        //get other project contact roles for project
        foreach ($this->app['idiorm']->getTable('projectcontact')
        ->select('projectcontact.*')
        ->select('contact.uuid')
        ->select('roletype')
        ->select('adiwg', 'role')
        ->join('roletype', array('projectcontact.roletypeid', '=', 'roletype.roletypeid'))
        ->join('contact', array('projectcontact.contactid', '=', 'contact.contactid'))
        -> where('projectid', $project['projectid'])
        ->find_many() as $object) {
            $roles[] = $object->as_array();
        }

        $role_map = [];

        array_walk($roles, function ($val) use (&$role_map) {
            $role_map[$val['roletypeid']][] = $val;
        });
//dump($role_map);
        //get products
        $assoc = [];
        if($withAssoc) {
            foreach ($this->app['idiorm']->getTable('product')
            ->select('productid')
            -> where('projectid', $project['projectid'])
            ->where('exportmetadata', TRUE)
            ->find_many() as $object) {
                $prd = $this->getProduct($object->get('productid'));
                $prd['assocType'] = 'projectProduct';
                $assoc[] = $prd;
            }

            //merge contacts
            foreach ($assoc as $arr) {
                foreach ($arr['contacts'] as $arr1) {
                    if(array_search ($arr1, $contacts) === FALSE){
                        $contacts[] = $arr1;
                   };
                };
            };
        }

        $data = array(
            'resourceType' => 'project',
            //get ScienceBase id
            'parentsciencebaseid' => $this->getGroupScienceBaseId(),
            'published' => $project['exportmetadata'],
            'organization' => $org,
            'resource' => $project,
            'keywords' => array_filter(explode('|', $project['keywords'])),
            "topics" => array_filter(explode('|', $project['topiccategory'])),
            "usertypes" => array_filter(explode('|', $project['usertype'])),
            "cats" => array_filter(explode('|', $project['projectcategory'])),
            "projectkeywords" => FALSE,
            'contacts' => $contacts,
            'roles' => $role_map,
            'links' => FALSE,
            'associated' => $assoc
        );

//dump($data);

        return $data;

    }

    function getProduct($id, $withAssoc = false, $group = false) {
        $contacts = array();
        $roles = array();

        $pquery = $this->app['idiorm']->getTable('metadataproduct')->select('metadataproduct.*');

        $probject = $pquery->find_one($id);

        if ($probject) {
            $product = $probject->as_array();
        } else {
            throw new \Exception("Couldn't find a product with id = $id.");
        };

        $product['featuresInherited'] = false;

        //get LCC contact
        $org = $this->app['idiorm']->getTable('metadatacontact')->where('contactId', $product['orgid'])->find_one()->as_array();

        $contacts[] = $org;

        //get other contacts for product
        foreach ($this->app['idiorm']->getTable('metadatacontact')->distinct()->select('metadatacontact.*')
        ->join('productcontact', array('metadatacontact.contactId', '=', 'productcontact.contactid'))
        ->where('productcontact.productid', $product['productid'])
        ->where_not_equal('contactId', $org['contactId'])
        ->find_many() as $object) {
            $contacts[] = $object->as_array();
        }

        //get other product contact roles for product
        foreach ($this->app['idiorm']->getTable('productcontact')
        ->select('productcontact.*')
        ->select('codename', 'role')
        ->select_expr('isoroletype.isoroletypeid', 'roletypeid')
        ->join('isoroletype', array('productcontact.isoroletypeid', '=', 'isoroletype.isoroletypeid'))
        ->where('productid', $product['productid'])
        ->find_many() as $object) {
            $roles[] = $object->as_array();
        }

        //get product dates
        $dates = [];
        $dObj = $this->app['idiorm']->getTable('productstatus')
        ->select_expr("MAX(effectivedate)", 'date')
        ->select('codename', 'dateType')
        ->join('datetype', array('datetype.datetypeid', '=', 'productstatus.datetypeid'))
        ->where('productid', $product['productid'])
        ->group_by('codename')
        ->find_many();

        if (!$dObj && !$group) {
            throw new \Exception("Unable to proceed: No status dates provided for product id: $id.");
        }

        foreach ($dObj as $object) {
            $dates[] = $object->as_array();
        }

        //get product links
        $links = [];
        foreach ($this->app['idiorm']->getTable('onlineresource')
        ->select('onlineresource.*')
        ->select('codename', 'function')
        ->join('onlinefunction', array('onlinefunction.onlinefunctionid', '=', 'onlineresource.onlinefunctionid'))
        ->where('productid', $product['productid'])
        ->find_many() as $object) {
            $links[] = $object->as_array();
        }

        //get product steps
        $steps = [];
        foreach ($this->app['idiorm']->getTable('productstep')
        ->select('productstep.*')
        ->select('contactid')
        ->select('role')
        ->join('productcontactlist', array('productcontactlist.productcontactid', '=', 'productstep.productcontactid'))
        ->where('productid', $id)
        ->order_by_asc('priority')
        ->find_many() as $object) {
            $steps[] = $object->as_array();
        }

        //get project and related products
        $prj = $product['projectid'] ? $this->getProject($product['projectid']) : false;
        $assoc = [];

        if($prj) {

            if($withAssoc) {
                if($prj['published']) {
                    $prj['assocType'] = 'largerWorkCitation';
                    $projuuid = $prj['resource']['resourceIdentifier'];
                    $parentmetadata = $prj;
                    $assoc = [$prj];
                }

                //get related project products
                foreach ($this->app['idiorm']->getTable('product')
                ->where('projectid', $product['projectid'])
                ->where('exportmetadata', TRUE)
                ->where_not_equal('productid', $id)
                ->find_many() as $object) {
                    $prd = $this->getProduct($object->productid);
                    $prd['assocType'] = 'projectProduct';
                    $assoc[$prd['resource']['resourceIdentifier']] = $prd;
                }
            }

          //if no product features, use project features if present
            if($product['features'] === NULL && isset($prj['resource']['features'])) {
                $product['features'] = $prj['resource']['features'];
                $product['bbox'] = $prj['resource']['bbox'];
                $product['featuresInherited'] = true;
            }
          }

          //get productgroup and related products
          if($product['productgroupid']) {
            $pg = $this->getProduct($product['productgroupid'], null, true);
            if($withAssoc) {
                if($pg['resource']['exportmetadata']) {
                    $pg['assocType'] = 'largerWorkCitation';
                    //$pguuid = $pg['resource']['resourceIdentifier'];
                    $assoc = [$pg];
                }

                //get related group products
                foreach ($this->app['idiorm']->getTable('product')
                ->where('productgroupid', $product['productgroupid'])
                ->where('exportmetadata', TRUE)
                ->where_not_equal('productid', $id)
                ->find_many() as $object) {
                  //if(!isset($assoc[$prd['resource']['resourceIdentifier']])) {
                      $prd = $this->getProduct($object->productid);
                      $prd['assocType'] = 'crossReference';
                      $assoc[$prd['resource']['resourceIdentifier']] = $prd;
                  //}
                }

            }

            //if no product features, use group features if present
            if($product['features'] === NULL && isset($pg['resource']['features'])) {
                $product['features'] = $pg['resource']['features'];
                $product['bbox'] = $pg['resource']['bbox'];
            }
        }

        //get grouped products
        if($product['isgroup']) {
          if($withAssoc) {
              //get related group products
              foreach ($this->app['idiorm']->getTable('product')
              ->where('productgroupid', $id)
              ->where('exportmetadata', TRUE)
              ->where_not_equal('productid', $id)
              ->find_many() as $object) {
                //if(!isset($assoc[$prd['resource']['resourceIdentifier']])) {
                    $prd = $this->getProduct($object->productid);
                    $prd['assocType'] = 'isComposedOf';
                    $assoc[$prd['resource']['resourceIdentifier']] = $prd;
                //}
              }

          }
        }

        //merge contacts
        foreach ($assoc as $arr) {
            if(isset($arr['contacts'])) {
                foreach ($arr['contacts'] as $arr1) {
                    if(array_search ($arr1, $contacts) === FALSE){
                	    $contacts[] = $arr1;
            	   }
                }
            }
        }

        //merge resource
        if(isset($pg)) {
          foreach ($product as $key => $value) {
            if (empty($value)) {
              $product[$key] = $pg['resource'][$key];
            }
          }
        }

        $return = array(
            'resourceType' => $product['resourcetype'],
            'parentsciencebaseid' => $this->getGroupScienceBaseId(),
            'organization' => $org,
            'resource' =>  $product,
            'keywords' => array_filter(explode('|', $product['keywords'])),
            'projectkeywords' => FALSE,
            'topics' => array_filter(explode('|', $product['topiccategory'])),
            'spatialformats' => array_filter(explode('|', $product['spatialformat'])),
            'epsgcodes' => array_filter(explode('|', $product['epsgcode'])),
            'wkt' => array_filter(explode('|', $product['wkt'])),
            'usertypes' => FALSE, //array_filter(explode('|', $product['usertype'])),
            'cats' => FALSE, //array_filter(explode('|', $product['productcategory'])),
            'contacts' => $contacts,
            'roles' => $roles,
            'dates' => $dates,
            'links' => $links,
            'steps' => $steps,
            'associated' => $assoc,
            'projectuuid' => isset($projuuid) ? $projuuid : null
        );

        //add project keywords if present
        if(isset($prj['keywords'])) {
            $return['projectkeywords'] = $prj['keywords'];
        }

        //add parent metadata reference if present
        if(isset($parentmetadata)) {

          $return['parentmetadata'] = $parentmetadata;
        }
        //merge group
        if(isset($pg)) {
          foreach ($return as $key => $value) {
            if (empty($value)) {
              $return[$key] = $pg[$key];
            }
          }
        }

        return $return;

    }

    function renderProject($project) {
      //echo $this->app['twig']->render('metadata/mdjson.json.twig', $project);
        return $this->app['twig']->render('metadata/mdjson.json.twig', $project);
    }

    function renderProduct($product) {
        return $this->app['twig']->render('metadata/mdjson.json.twig', $product);
    }

    function saveProject($id, $schema = FALSE, $_conn = FALSE) {
        $schema = $schema ? $schema : $this->app['session']->get('schema');
        //if none, create the db file
        $this->buildMetaDB(FALSE, $schema);

        $conn = $_conn ? $_conn : $this->app['dbs'][$schema];
        $sql = "SELECT * FROM project WHERE projectid = ?";

        $probject = $this->getProject($id, TRUE);
        $uuid = $probject['resource']['resourceIdentifier'];
        $project = $conn->fetchAssoc($sql, array($uuid));
        $json = $this->renderProject($probject);
        $xml = $this->translate($json);
        $html = $this->translate($json, 'html');
        $data = array(
                'projectcode' => $probject['resource']['projectcode'],
                'groupid' => $schema,
                'json' => $json,
                'xml' => $xml,
                'html' => $html,
                'metadataupdate' => (new \DateTime())->format(\DateTime::ISO8601)
            );

        if($project) {
            $conn->update('project', $data, array('projectid' => $uuid));
        } else {
            $data['projectid'] = $uuid;
            $conn->insert('project', $data);
        }

        if(!$_conn) {
            $conn->close();
        }

        //update the metadata info
        $object = $this->app['idiorm']->getTable('project')->find_one($id);
        $object->set('metadataupdate', $data['metadataupdate']);
        $object->save();
    }

    function deleteProject($id) {
        $conn = $this->app['dbs'][$this->app['session']->get('schema')];
        $conn->delete('project', array('projectid' => $id));
    }

    function saveProduct($id, $schema = FALSE, $_conn = FALSE) {
        $schema = $schema ? $schema : $this->app['session']->get('schema');
        //if none, create the db file
        $this->buildMetaDB(FALSE, $schema);

        $conn = $_conn ? $_conn : $this->app['dbs'][$schema];
        $sql = "SELECT * FROM product WHERE productid = ?";

        $probject = $this->getProduct($id, TRUE);
        $uuid = $probject['resource']['resourceIdentifier'];
        $product = $conn->fetchAssoc($sql, array($uuid));
        $json = $this->renderProduct($probject);
        $xml = $this->translate($json);
        $html = $this->translate($json, 'html');
        $data = array(
                'projectid' => $probject['projectuuid'],
                'groupid' => $schema,
                'projectcode' => $probject['resource']['projectcode'],
                'json' => $json,
                'xml' => $xml,
                'html' => $html,
                'metadataupdate' => (new \DateTime())->format(\DateTime::ISO8601)
            );

        if($product) {
            $conn->update('product', $data, array('productid' => $uuid));
        } else {
            $data['productid'] = $uuid;
            $conn->insert('product', $data);
        }

        if(!$_conn) {
            $conn->close();
        }

        //update the metadata info
        $object = $this->app['idiorm']->getTable('product')->find_one($id);
        $object->set('metadataupdate', $data['metadataupdate']);
        $object->save();
    }

    function deleteProduct($id) {
        $conn = $this->app['dbs'][$this->app['session']->get('schema')];
        $conn->delete('product', array('productid' => $id));
    }

    function translate($json, $format='iso19115_2') {
        //write to temp file to support cross-platform
        $temp = tmpfile();
        fwrite($temp, $json);
        fseek($temp, 0);
        $meta = stream_get_meta_data($temp);
        exec("mdtranslator translate -o -r mdJson -w $format " . $meta['uri'], $out, $code);
        fclose($temp);

        $xml = empty($out) ? FALSE : json_decode($out[0]);

        if ($code > 0) {
            throw new \Exception("mdTranslator error.");
        } elseif (!is_object($xml) || !$xml->writerPass) {
            throw new \Exception("JSON did not validate.");
        }

        return $xml->writerOutput;
    }

    function buildMetaDB($path = FALSE, $schema = FALSE) {
        if(!$path) {
            if($schema) {
            //get the file from $app['dbs'] config
            $path = $this->app['dbOptions'][$schema]['path'];
            } else {
                throw new \Exception("buildMetaDB failed. No schema or path supplied.");
            }
        }

        if(!file_exists($path)) {
            $conn = $this->app['dbs'][$schema];

            $schema = new \Doctrine\DBAL\Schema\Schema();
            $project = $schema->createTable("project");
            $project->addColumn("projectid", "string");
            $project->addColumn("projectcode", "string");
            $project->addColumn("json", "string");
            $project->addColumn("xml", "string");
            $project->addColumn("html", "string");
            $project->addColumn("metadataupdate", "string");
            $project->addColumn("groupid", "string");
            $project->setPrimaryKey(array("projectid"));

            $product = $schema->createTable("product");
            $product->addColumn("productid", "string");
            $product->addColumn("projectid", "string", ['notnull' => false]);
            $product->addColumn("projectcode", "string", ['notnull' => false]);
            $product->addColumn("json", "string");
            $product->addColumn("xml", "string");
            $product->addColumn("html", "string");
            $product->addColumn("metadataupdate", "string");
            $product->addColumn("groupid", "string");
            $product->setPrimaryKey(array("productid"));
            $product->addForeignKeyConstraint(
                $project,
                array("projectid"),
                array("projectid"),
                array("onUpdate" => "CASCADE","onDelete" => "SET NULL")
            );

            $queries = $schema->toSql($conn->getDatabasePlatform()); // get queries to create this schema.

            foreach ($queries as $sql) {
                $conn->exec($sql);
            }

            chmod($path, 0664);
            return $conn;
        }

        return false;
    }
}
