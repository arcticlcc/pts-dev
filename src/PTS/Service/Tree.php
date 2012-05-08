<?php

namespace PTS\Service;

use Symfony\Component\HttpFoundation\Response;
use PTS\Service\TreeNode;

/**
 * A quick and dirty service to render a JSON ExtTree.
 * 
 * @version .1
 * @author http://miamicoder.com/2010/ext-js-with-php-how-to-create-nodes-for-a-treepanel/ 
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Tree {

    public $nodes = array();

    function add($n) {
        $this->nodes[] = $n;
    }

    function node($id = "",$text = "",$iconCls = "", $leaf = true, $draggable = false,
            $href = "#", $hrefTarget = "") {

        $n = new TreeNode($id,$text,$iconCls,$leaf,$draggable,
            $href,$hrefTarget);

        return $n;
    }

    function toJson() {
        return json_encode($this->nodes[0]);
    }
}
 
?>
