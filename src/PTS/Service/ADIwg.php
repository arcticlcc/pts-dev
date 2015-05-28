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
    protected $project;

    public function __construct($app) {
        $this->app = $app;
    }

    function getProject($id) {
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
            $this->project = $project;
        } else {
            throw new \Exception("Couldn't find a project with id = $id.");
        };

        //get LCC contact
        $org = $this->app['idiorm']->getTable('metadatacontact')->where('contactId', $project['orgid'])->find_one()->as_array();

        $contacts[] = $org;

        //get other contacts for project
        foreach ($this->app['idiorm']->getTable('metadatacontact')->distinct()->select('metadatacontact.*')
        ->join('projectcontact', array('metadatacontact.contactId', '=', 'projectcontact.contactid'))
        -> where('projectid', $project['projectid'])
        -> where_not_equal('contactId', $org['contactId'])
        ->find_many() as $object) {
            $contacts[] = $object->as_array();
        }

        //get other project contact roles for project
        foreach ($this->app['idiorm']->getTable('projectcontact')
        ->select('projectcontact.*','roletype','adiwg')
        ->select('roletype')
        ->select('adiwg')
        ->join('roletype', array('projectcontact.roletypeid', '=', 'roletype.roletypeid'))
        -> where('projectid', $project['projectid'])
        ->find_many() as $object) {
            $roles[] = $object->as_array();
        }

        return $this->app['twig']->render('metadata/project.json.twig', array(
            'resourceType' => "project",
            'organization' => $org,
            'resource' => $project,
            'keywords' => array_filter(explode('|', $project['keywords'])),
            "topics" => array_filter(explode('|', $project['topiccategory'])),
            "usertypes" => array_filter(explode('|', $project['usertype'])),
            "projectcats" => array_filter(explode('|', $project['projectcategory'])),
            'contacts' => $contacts,
            'roles' => $roles
        ));

    }

    function saveProject($id) {
        $conn = $this->app['dbs'][$this->app['session']->get('schema')];
        $sql = "SELECT * FROM project WHERE projectid = ?";

        $project = $conn->fetchAssoc($sql, array((int) $id));

        $json = $this->getProject($id);
        $xml = $this->translate($json);
        $data = array(
                'uuid' => $this->project['projectIdentifier'],
                'projectcode' => $this->project['projectcode'],
                'json' => $json,
                'xml' => $xml
            );

        if($project) {
            $conn->update('project', $data, array('projectid' => $id));
        } else {
            $data['projectid'] = $id;
            $conn->insert('project', $data);
        }
    }

    function deleteProject($id) {
        $conn = $this->app['dbs'][$this->app['session']->get('schema')];
        $conn->delete('project', array('projectid' => $id));
    }

    function translate($json, $format='iso19115_2') {
        //write to temp file to support cross-platform
        $temp = tmpfile();
        fwrite($temp, $json);
        fseek($temp, 0);
        $meta = stream_get_meta_data($temp);
        exec("mdtranslator translate -o -w $format " . $meta['uri'], $out, $code);
        fclose($temp);

        $xml = empty($out) ? FALSE : json_decode($out[0]);

        if ($code > 0) {
            throw new \Exception("mdTranslator error.");
        } elseif (!is_object($xml) || !$xml->writerPass) {
            throw new \Exception("JSON did not validate.");
        }

        return $xml->writerOutput;
    }

}
?>
