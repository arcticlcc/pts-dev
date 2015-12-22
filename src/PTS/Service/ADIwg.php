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

    function getProject($id, $withAssoc = false) {
        $contacts = array();
        $roles = array();

        $pquery = $this->app['idiorm']->getTable('metadataproject')->select('metadataproject.*');

        if (strpos($id, '-') === FALSE) {
            $probject = $pquery->find_one($id);
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
        ->join('projectcontact', array('metadatacontact.contactId', '=', 'projectcontact.contactid'))
        -> where('projectcontact.projectid', $project['projectid'])
        -> where_not_equal('contactId', $org['contactId'])
        ->find_many() as $object) {
            $contacts[] = $object->as_array();
        }

        //get other project contact roles for project
        foreach ($this->app['idiorm']->getTable('projectcontact')
        ->select('projectcontact.*')
        ->select('roletype')
        ->select('adiwg', 'role')
        ->join('roletype', array('projectcontact.roletypeid', '=', 'roletype.roletypeid'))
        -> where('projectid', $project['projectid'])
        ->find_many() as $object) {
            $roles[] = $object->as_array();
        }

        //get products
        $assoc = [];
        if($withAssoc) {
            foreach ($this->app['idiorm']->getTable('product')
            ->select('productid')
            -> where('projectid', $project['projectid'])
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

        return array(
            'resourceType' => 'project',
            'organization' => $org,
            'resource' => $project,
            'keywords' => array_filter(explode('|', $project['keywords'])),
            "topics" => array_filter(explode('|', $project['topiccategory'])),
            "usertypes" => array_filter(explode('|', $project['usertype'])),
            "cats" => array_filter(explode('|', $project['projectcategory'])),
            "projectkeywords" => FALSE,
            'contacts' => $contacts,
            'roles' => $roles,
            'links' => FALSE,
            'associated' => $assoc
        );

    }

    function getProduct($id, $withAssoc = false) {
        $contacts = array();
        $roles = array();

        $pquery = $this->app['idiorm']->getTable('metadataproduct')->select('metadataproduct.*');

        $probject = $pquery->find_one($id);

        if ($probject) {
            $product = $probject->as_array();
        } else {
            throw new \Exception("Couldn't find a product with id = $id.");
        };

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
        foreach ($this->app['idiorm']->getTable('productstatus')
        ->select_expr("MAX(effectivedate)", 'date')
        ->select('codename', 'dateType')
        ->join('datetype', array('datetype.datetypeid', '=', 'productstatus.datetypeid'))
        ->where('productid', $product['productid'])
        ->group_by('codename')
        ->find_many() as $object) {
            $dates[] = $object->as_array();
        }

        //get product links
        foreach ($this->app['idiorm']->getTable('onlineresource')
        ->select('onlineresource.*')
        ->select('codename', 'function')
        ->join('onlinefunction', array('onlinefunction.onlinefunctionid', '=', 'onlineresource.onlinefunctionid'))
        ->where('productid', $product['productid'])
        ->find_many() as $object) {
            $links[] = $object->as_array();
        }

        //get project and related products
        if($withAssoc) {
            $prj = $this->getProject($product['projectid']);
            $prj['assocType'] = 'largerWorkCitation';
            $projuuid = $prj['resource']['resourceIdentifier'];
            $assoc = [$prj];

            //get products
            foreach ($this->app['idiorm']->getTable('product')
            ->where('projectid', $product['projectid'])
            ->where_not_equal('productid', $id)
            ->find_many() as $object) {
                $prd = $this->getProduct($object->productid);
                $prd['assocType'] = 'projectProduct';
                $assoc[] = $prd;
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
        }else {
            $assoc = [];
        }

        //if no project features, use product features if present
        if($product['features'] === NULL && !empty($assoc)) {
            $product['features'] = $assoc[0]['resource']['features'];
            $product['bbox'] = $assoc[0]['resource']['bbox'];
            $product['featuresInherited'] = true;
        }

        $return = array(
            'resourceType' => $product['resourcetype'],
            'organization' => $org,
            'resource' => $product,
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
            'associated' => $assoc,
            'projectuuid' => isset($projuuid) ? $projuuid : null
        );

        //add product keywords if present
        if(!empty($assoc)) {
            $return['projectkeywords'] = $assoc[0]['keywords'];
        }

        return $return;
    }

    function renderProject($project) {
        return $this->app['twig']->render('metadata/mdjson.json.twig', $project);
    }

    function renderProduct($product) {
        return $this->app['twig']->render('metadata/mdjson.json.twig', $product);
    }

    function saveProject($id, $schema = FALSE) {
        $schema = $schema ? $schema : $this->app['session']->get('schema');
        //if none, create the db file
        $this->buildMetaDB(FALSE, $schema);

        $conn = $this->app['dbs'][$schema];
        $sql = "SELECT * FROM project WHERE projectid = ?";

        $project = $conn->fetchAssoc($sql, array((int) $id));

        $probject = $this->getProject($id, TRUE);
        $json = $this->renderProject($probject);
        $xml = $this->translate($json);
        $html = $this->translate($json, 'html');
        $data = array(
                'projectid' => $probject['resource']['resourceIdentifier'],
                'projectcode' => $probject['resource']['projectcode'],
                'groupid' => $schema,
                'json' => $json,
                'xml' => $xml,
                'html' => $html,
                'metadataupdate' => (new \DateTime())->format(\DateTime::ISO8601)
            );

        if($project) {
            $conn->update('project', $data, array('projectid' => $data['projectid']));
        } else {
            //$data['projectid'] = $id;
            $conn->insert('project', $data);
        }

        $conn->close();

        //update the metadata info
        $object = $this->app['idiorm']->getTable('project')->find_one($id);
        $object->set('metadataupdate', $data['metadataupdate']);
        $object->save();
    }

    function deleteProject($id) {
        $conn = $this->app['dbs'][$this->app['session']->get('schema')];
        $conn->delete('project', array('projectid' => $id));
    }

    function saveProduct($id, $schema = FALSE) {
        $schema = $schema ? $schema : $this->app['session']->get('schema');
        //if none, create the db file
        $this->buildMetaDB(FALSE, $schema);

        $conn = $this->app['dbs'][$schema];
        $sql = "SELECT * FROM product WHERE productid = ?";

        $product = $conn->fetchAssoc($sql, array((int) $id));

        $probject = $this->getProduct($id, TRUE);
        $json = $this->renderProduct($probject);
        $xml = $this->translate($json);
        $html = $this->translate($json, 'html');
        $data = array(
                'productid' => $probject['resource']['resourceIdentifier'],
                'projectid' => $probject['projectuuid'],
                'groupid' => $schema,
                'projectcode' => $probject['resource']['projectcode'],
                'json' => $json,
                'xml' => $xml,
                'html' => $html,
                'metadataupdate' => (new \DateTime())->format(\DateTime::ISO8601)
            );

        if($product) {
            $conn->update('product', $data, array('productid' => $data['productid']));
        } else {
            //$data['productid'] = $id;
            $conn->insert('product', $data);
        }

        $conn->close();

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
            $product->addColumn("projectid", "string", ['notnull' => FALSE]);
            $product->addColumn("projectcode", "string");
            $product->addColumn("json", "string");
            $product->addColumn("xml", "string");
            $product->addColumn("html", "string");
            $product->addColumn("metadataupdate", "string");
            $product->addColumn("groupid", "string");
            $product->setPrimaryKey(array("productid"));
            $product->addForeignKeyConstraint($project,
                array("projectid"), array("projectid"), array("onUpdate" => "CASCADE"));

            $queries = $schema->toSql($conn->getDatabasePlatform()); // get queries to create this schema.

            foreach ($queries as $sql) {
                $conn->exec($sql);
            }

            chmod($path, 0664);
            return $conn;
        }

        return FALSE;
    }

}
?>
