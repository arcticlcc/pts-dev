<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

/**
 * Controller for project.
 *
 * @uses ControllerProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Project implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];
        $table = 'project';

        $controllers->match('projectmetadata/{id}', function (Application $app, Request $request, $id) {
            try{
                $app['db']->transactional(function($conn) use ($app, $request, $id) {
                    $values = json_decode($request->getContent());
                    $projcat = $app['idiorm']->getTable('projectprojectcategory');
                    $usertype = $app['idiorm']->getTable('projectusertype');
                    $topic = $app['idiorm']->getTable('projecttopiccategory');

                    if($request->getMethod() === 'PUT') {
                        //delete any existing records
                        $projcat->where_equal('projectid', $id)->delete_many();
                        $usertype->where_equal('projectid', $id)->delete_many();
                        $topic->where_equal('projectid', $id)->delete_many();
                    }

                    //create new records based on submitted data
                    foreach ($values->projectcategory as $key => $value) {
                        $projcat->create();
                        $projcat->set('projectid', $id);
                        $projcat->set('projectcategoryid', $value);
                        $projcat->set('priority', $key);
                        $projcat->save();
                    }

                    foreach ($values->usertype as $key => $value) {
                        $usertype->create();
                        $usertype->set('projectid', $id);
                        $usertype->set('usertypeid', $value);
                        $usertype->set('priority', $key);
                        $usertype->save();
                    }

                    foreach ($values->topiccategory as $value) {
                        $topic->create();
                        $topic->set('projectid', $id);
                        $topic->set('topiccategoryid',$value);
                        $topic->save();
                    }

                });

                $object = $app['idiorm']->getTable('projectmetadata')->find_one($id);
                $result = $object->as_array();
                $app['json']->setData($result);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                $app['json']->setAll(null, 500, false, $exc->getMessage());
            }

            return $app['json']->getResponse();

        })->method('PUT');

        $controllers->get('project/{id}/metadata.{format}', function (Application $app, Request $request, $id, $format) {
            try{
                $json = $app['adiwg']->renderProject($app['adiwg']->getProject($id, TRUE));
                $ct = "application/$format";

                switch ($format) {
                    case 'xml':
                        $out = $app['adiwg']->translate($json);
                        break;
                    case 'html':
                        $out = $app['adiwg']->translate($json, 'html');
                        $ct = "text/html";
                        break;
                    case 'json':
                    default:
                       $out = $request->get('pretty') ? json_encode(json_decode($json), JSON_PRETTY_PRINT) : $json;
                }

                $response = new Response($out, 200, array(
                    'Content-type' => "$ct; charset=utf-8"
                ));
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $response = $app['json']->setAll(null, 500, false, $exc->getMessage())->getResponse();
            }

            return $response;

        })->value('format', 'json');

        $controllers->match('project/{id}/metadata/publish', function (Application $app, Request $request, $id) {
            try{
                $app['adiwg']->saveProject($id);

                $json[] = array('success' => true);
                $response = $app['json']->setData($json)->getResponse(true);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $response = $app['json']->setAll(null, 500, false, $exc->getMessage())->getResponse();
            }

            return $response;

        })->method('GET|PUT|POST');

        $controllers->match('project/{id}/metadata/publish', function (Application $app, Request $request, $id) {
            try{
                $app['adiwg']->deleteProject($id);

                $json[] = array('success' => true);
                $response = $app['json']->setData($json)->getResponse(true);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $response = $app['json']->setAll(null, 500, false, $exc->getMessage())->getResponse();
            }

            return $response;

        })->method('DELETE');

        //TODO: make rest variables singular
        $controllers->get('project/{id}/contacts', function (Application $app, Request $request, $id) {
            $table = 'projectcontactlist'; //need to use projectcontactlist view

            $app['getRelated']($request, $table, 'projectid', $id);

            return $app['json']->getResponse();
        });

        $controllers->get('project/{id}/funder', function (Application $app, Request $request, $id) {
            $table = 'projectfunderlist'; //need to use projectfunderlist view

            $app['getRelated']($request, $table, 'projectid', $id);

            return $app['json']->getResponse();
        });

        $controllers->get('project/{id}/projectkeyword', function (Application $app, Request $request, $id) {
            $table = 'projectkeywordlist'; //need to use projectkeywordlist view

            $app['getRelated']($request, $table, 'projectid', $id);

            return $app['json']->getResponse();
        });

        $controllers->get('project/{id}/task', function (Application $app, Request $request, $id) {
            $table = 'modification';
            $query = array('modtypeid' => 4);

            $app['getRelated']($request, $table, 'projectid', $id, $query);

            return $app['json']->getResponse();
        });

        $controllers->get('project/{id}/tree', function (Application $app, Request $request, $id) {
            //check to see if the full tree is requested
            $long = $request->get('short') ? false : true;

            $createTree = function($rec) use ($app, $id, $long) {
                $aid = $rec['modificationid'];
                $fkey = array('modificationid'=>$aid); //foreign key for modification(agreement)
                //create nodes
                $icon = $rec['ismodified'] ? 'pts-modified-agreement-folder' : 'pts-agreement-folder';
                $node = $app['tree']->node("af-$aid",$rec['title'],$icon,false);
                $node->setAttribute('dataid',$aid);
                $node->setAttribute('type',$rec['typecode']);
                $node->setAttribute('code',$rec['modificationcode']);
                if($rec['parentcode']) {
                    $node->setAttribute('parentcode',$rec['parentcode']);
                }
                /*$node->setAttribute('fkey',array(
                    'projectid' => $rec['projectid'],
                    'parentmodificationid' => $rec['parentmodificationid']
                ));*/
                if($long) {
                    $dels = $app['tree']->node("df-$aid",'Deliverables','task-folder',false);
                    $dels->setAttribute('typeid',30);
                    $dels->setAttribute('fkey',$fkey);
                    $dels->setAttribute('defIcon','pts-page-blue');

                    $funds = $app['tree']->node("ff-$aid",'Funds','task-folder',false);
                    $funds->setAttribute('typeid',50);
                    $funds->setAttribute('fkey',$fkey);
                    $funds->setAttribute('defIcon','pts-money-dollar');

                    $tasks = $app['tree']->node("tf-$aid",'Tasks','task-folder',false);
                    $tasks->setAttribute('typeid',40);
                    $tasks->setAttribute('fkey',$fkey);
                    $tasks->setAttribute('defIcon','pts-page-orange');

                    //get deliverables/tasks
                    $delRecs = $app['idiorm']->getRelated(true, 'deliverableall', 'modificationid', $aid, null, 'duedate', 'ASC');
                    $dfkey = $fkey;
                    foreach($delRecs as $d) {
                        $cls = false;
                        $did = $d['deliverableid'] .'-'. $d['modificationid'];
                        $dataid = $d['modificationid'] .'/deliverable/'. $d['deliverableid'];
                        //create deliverable node
                        $icon = $d['parentmodificationid'] ? 'pts-page-bluecopy' : 'pts-page-blue'; //check if the deliverable is a mod
                        $dnode = $app['tree']->node("d-$did",$d['title'],$icon,true);
                        //set attributes
                        /*if($d['parentmodificationid']) { //if the deliverable is a mod
                            $dfkey[] = array($d['parentdeliverableid'], 'parentdeliverableid');
                            $dfkey[] = array($d['parentmodificationid'], 'parentmodificationid');
                        }*/

                        $dnode->setAttribute('dataid',$dataid);
                        /*
                        //invalid field is deprecated
                        if($d['invalid']) {
                            $cls = 'pts-deliverable-invalid';
                        }*/
                        if($d['modified']) {
                            $dnode->setAttribute('readonly','true');
                            $cls .= ' pts-deliverable-modified';
                        }
                        if($d['status'] == 'Canceled') {
                            $cls .= ' pts-deliverable-canceled';
                        }
                        if($cls) {
                            $dnode->setAttribute('cls',$cls);
                        }

                        if($d['parentdeliverableid']) {
                            $dnode->setAttribute('parentItm','d-'. $d['parentdeliverableid'] .'-'. $d['parentmodificationid']);
                        }
                        //$dnode->setAttribute('fkey',$dfkey);

                        switch ($d['deliverabletypeid']) {
                            case 4: //get tasks
                            case 7:
                                /*$tnode = $app['tree']->node("t-$did",$d['title'],'task',true);
                                $tnode->setAttribute('dataid',$dataid);
                                $tnode->setAttribute('fkey',array($d['modificationid'], 'modificationid'));*/
                                $dnode->setAttribute('iconCls','pts-page-orange');
                                $tasks->addChild($dnode);
                                break;
                            default:
                                /*$dnode = $app['tree']->node("d-$did",$d['title'],'task',true);
                                $dnode->setAttribute('dataid',$dataid);
                                $dnode->setAttribute('fkey',array($d['modificationid'], 'modificationid'));*/
                                $dels->addChild($dnode);

                        }
                    }

                    //get funds
                    $fundRecs = $app['idiorm']->getRelated(true, 'funding', 'modificationid', $aid);
                    foreach($fundRecs as $f) {
                        $fid = $f['fundingid'];
                        $fnode = $app['tree']->node("f-$fid",$f['title'],'pts-money-dollar',true);
                        $fnode->setAttribute('dataid',$fid);
                        //$fnode->setAttribute('fkey',$fkey);
                        $funds->addChild($fnode);

                    }

                    //add child nodes
                    $node->addChild($dels);
                    $node->addChild($funds);
                    $node->addChild($tasks);
                }
                return $node;
            };

            try {
                //create root node($id,$text,$iconCls,$leaf)
                $rootNode = $app['tree']->node('root','.','',false);

                if($long) {
                    $propNode = $app['tree']->node('prt-0','Proposals','task-folder',false);
                    $propNode->setAttribute('typeid', 10);
                    $propNode->setAttribute('fkey',array(
                        'projectid'=>$id
                    ));
                    $propNode->setAttribute('defIcon','pts-page-white');

                    $agreeNode = $app['tree']->node('art-0','Agreements','task-folder',false);
                    $agreeNode->setAttribute('typeid', 20);
                    $agreeNode->setAttribute('fkey',array(
                        'projectid'=>$id
                    ));
                    $agreeNode->setAttribute('defIcon','pts-agreement-folder');
                }
                //get all related modifications
                $m = $app['idiorm']->getRelated(true, 'modificationlist', 'projectid', $id, null, 'modificationid');
                $mod = array();
                $agree = array();

                //filter by type
                foreach($m as $r) {
                    $rid = $r['modificationid'];
                    switch ($r['modtypeid']) {
                        case 9: //get pre-proposals
                            /*$node = $app['tree']->node("pp-$rid",$r['title'],'task',true);
                            $node->setAttribute('dataid',$rid);
                            $propNode->addChild($node);

                            break;*/
                        case 4: //get proposals
                            if($long) {
                                $node = $app['tree']->node("pr-$rid",$r['title'],'pts-page-white',true);
                                $node->setAttribute('dataid',$rid);
                                $node->setAttribute('type',$r['typecode']);
                                /*$node->setAttribute('fkey',array(
                                    array($r['projectid'], 'projectid')
                                ));*/
                                $propNode->addChild($node);
                            }
                            break;
                        default:
                            if($r['parentmodificationid']) {
                                $mod[] = $r; //get mods
                            }else {
                                $agree[] = $r; //agreements
                            }
                    }
                }

                //loop through agreements,
                //get deliverables, tasks, funds, mods
                foreach($agree as $r) {
                    $aid = $r['modificationid'];
                    //create the agreement node
                    $node = $createTree($r);
                    if($long) {
                        //add modification node
                        $modNode = $app['tree']->node("mf-$aid",'Modifications','task-folder',false);
                        $modNode->setAttribute('typeid', 60);
                        $modNode->setAttribute('fkey',array(
                            'projectid'=>$r['projectid'],
                            'modtypeid'=>$r['modtypeid'],
                            'parentmodificationid'=>$aid
                        ));
                        $modNode->setAttribute('defIcon','pts-agreement-folder');
                        $modNode->setAttribute('parentcode', $r['modificationcode']);
                    }

                    //get mod records for this agreement
                    $modRecs = array_filter($mod, function($mod) use ($r) {
                        return $mod['parentmodificationid'] === $r['modificationid'];
                    });
                    //create and add nodes to modNode
                    foreach($modRecs as $mr) {
                        if($long) {
                            $modNode->addChild($createTree($mr));
                        }else {
                            $mn = $createTree($mr);
                            $mn->setAttribute('hilite',true);
                            $node->addChild($mn);
                        }
                    }
                    if($long) {
                        //add modeNode to agreement node
                        $node->addChild($modNode);
                        //add to root agreement node
                        $agreeNode->addChild($node);
                    } else {
                        $rootNode->addChild($node);
                    }
                }

                if($long) {
                    //add proposals
                    $rootNode->addChild($propNode);
                    //add agreements
                    $rootNode->addChild($agreeNode);
                }

                $app['tree']->add($rootNode);

                $app['json']->setData($app['tree']->nodes[0]);

            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse(true);
        });

        return $controllers;
    }


}

?>
