<?php

namespace PTS\Service;

use Symfony\Component\HttpFoundation\Response;

/**
 * A quick and dirty service to create an Ext Treenode.
 *
 * @version .1
 * @author http://miamicoder.com/2010/ext-js-with-php-how-to-create-nodes-for-a-treepanel/
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class TreeNode {

    public $children;
    public $text;
    public $id;
//    public $data = array();
    public $iconCls;
    public $leaf;
    public $draggable;
    //public $href;
    //public $hrefTarget;

    function  __construct($id = "",$text = "",$iconCls = "", $leaf = true, $draggable = false,
            $href = "#", $hrefTarget = "") {

        $this->id = $id;
        $this->text = $text;
        $this->iconCls = $iconCls;
        $this->leaf = $leaf;
        $this->draggable = $draggable;
        //$this->href = $href;
        //$this->hrefTarget = $hrefTarget;

        //if this is not a leaf, we must add a children array
        if(!$this->leaf) {
             $this->children = array();
        }
    }

    function setAttribute($name, $value) {
        $this->$name = $value;
    }

    function addChild($node) {
        $this->children[] = $node;
    }

    function addChildren(Array $children, TreeNode &$parent) {
        //check to see if we're in the root
        if(!array_key_exists('text', $children)) {
            foreach($children as $child) {
                 $parent->addChildren($child, $parent);
            }
        }else{
            $newNode = new TreeNode();
            foreach($children as $k => $att) {
                if($k !== "children") {
                    $newNode->setAttribute($k,$att);
                }
            }

            $parent->addChild($newNode);

            if(!$newNode->leaf && isset($children["children"])) {
                foreach ($children["children"] as $node) {
                     $newNode->addChildren($node, $newNode);
                }
            }
        }

    }
}

?>
