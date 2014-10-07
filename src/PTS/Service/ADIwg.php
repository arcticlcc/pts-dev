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
            'metadataScope' => "project",
            'organization' => $org,
            'resource' => $project,
            'keywords' => array_filter(explode('|', $project['keywords'])),
            'contacts' => $contacts,
            'roles' => $roles
        ));

    }

    function saveProject() {
        $sql = "SELECT * FROM project WHERE projectid = ?";
        $project = $this->app['dbs']['sqlite']->fetchAssoc($sql, array((int) $id));

    }

    function deleteProject() {

    }

    function updateProject() {

    }

    function translate($json, $format='iso19115_2') {
        //write to temp file to support cross-platform
        $temp = tmpfile();
        fwrite($temp, $json);
        fseek($temp, 0);
        $meta = stream_get_meta_data($temp);
        exec("mdtranslator translate -o -w $format " . $meta['uri'], $meta, $code);
        fclose($temp);
        // this removes the file
        $xml = json_decode($meta[0]);

        if ($code > 0) {
            throw new \Exception("mdTranslator error.");
        } elseif (!is_object($xml) || !$xml->writerPass) {
            throw new \Exception("JSON did not validate.");
        }

        return $xml->writerOutput;
    }

}
?>
