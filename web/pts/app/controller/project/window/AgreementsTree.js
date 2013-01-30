/**
 * Project AgreementsTree controller.
 */
Ext.define('PTS.controller.project.window.AgreementsTree', {
    extend: 'Ext.app.Controller',

    views: [
        'project.window.AgreementsTree',
        'project.window.ItemDetail'
    ],
    models: [
        'AgreementsTree'
    ],
    stores: [
        'AgreementsTree'
    ],
    refs: [{
        ref: 'itemDetail',
        selector: 'agreementitemdetail'
    },{
        ref: 'treeView',
        selector: 'agreementstree treeview'
    }],

    init: function() {

        /*var list = this.getController('project.tab.ProjectList')

        // Remember to call the init method manually
        list.init();*/

        this.control({
            'agreementstree': {
                beforerender: this.beforeRender
            },
            'agreementstree treeview': {
                afterrender: this.afterRenderView,
                beforedrop: this.beforeDrop
            },
            'agreementstree tool[type=expand]': {
                click: this.expandAll
            },
            'agreementstree tool[type=collapse]': {
                click: this.collapseAll
            },
            'agreementstree tool[type=refresh]': {
                click: this.refresh
            }
        });

        // We listen for the application-wide closeproject event
        this.application.on({
            closeproject: this.onCloseProject,
            scope: this
        });
    },

    /**
     * Configure the store
     */
    beforeRender: function(tree) {
        var id = tree.up('window').projectId,
        store= tree.getStore();

        //override store proxy based on projectid
        store.setProxy({
            type: 'ajax',
            url: '../project/' + id + '/tree',
            reader: {
                type: 'json'
            }
        });

        //load the store
        store.load();
    },

    /**
     * Configure the dropzone
     * Only drop from "deliverables" are allowed
     */
    afterRenderView: function(view) {
        var plugin = view.getPlugin('agreementsddplugin'),
        dragZone = plugin.dragZone;
        dragZone.isPreventDrag = function(e, record) {
            return (record.get('allowDrag') === false) || record.parentNode.get('typeid') !== 30 || !!e.getTarget(this.view.expanderSelector);
        };

        plugin.dropZone.onNodeDrop = function (node, dragZone, e, data) { //TODO: this is fixed in 4.1
            var me = this,
            dropHandled = false,

            // Create a closure to perform the operation which the event handler may use.
            // Users may now set the wait parameter in the beforedrop handler, and perform any kind
            // of asynchronous processing such as an Ext.Msg.confirm, or an Ajax request,
            // and complete the drop gesture at some point in the future by calling either the
            // processDrop or cancelDrop methods.
            dropHandlers = {
                wait : false,
                processDrop : function (d) {
                    data.records = d ? d : data.records; //allow modified data object to be passed
                    me.invalidateDrop();
                    me.handleNodeDrop(data, me.overRecord, me.currentPosition);

                    dropHandled = true;
                    me.fireViewEvent('drop', node, data, me.overRecord, me.currentPosition);
                    return data;
                },

                cancelDrop : function () {
                    me.invalidateDrop();
                    dropHandled = true;
                }
            },
            performOperation = false;

            if (me.valid) {
                performOperation = me.fireViewEvent('beforedrop', node, data, me.overRecord, me.currentPosition, dropHandlers);
                if (dropHandlers.wait) {
                    return;
                }

                if (performOperation !== false) {
                    // If either of the drop handlers were called in the event handler, do not do it again.
                    if (!dropHandled) {
                        dropHandlers.processDrop();
                    }
                }
            }
            return performOperation;
        };
        plugin.dropZone.isValidDropPoint = function(node, position, dragZone, e, data) {

            /*COPIED from ViewDropZone.js***/
            if (!node || !data.item) {
                return false;
            }

            var view = this.view,
                targetNode = view.getRecord(node),
                draggedRecords = data.records,
                dataLength = draggedRecords.length,
                ln = draggedRecords.length,
                i, record,
                findChild = function(child) {
                    return child.get('parentItm') === record.getId();
                };

            /*edit*/

            //Must be appended to a deliverable folder
            if(!(targetNode.get('typeid') == 30 && position === 'append')) {
                return false;
            }
            //Logic to prevent multiple copies in the same folder
            for (i = 0; i < ln; i++) {
                record = draggedRecords[i];

                if (targetNode.contains(record)) {
                    return false;
                }
                //make sure the deliverable is not in the mod already
                if (targetNode.findChildBy(findChild)) {return false;}
            }

            /*end edit*/

            // No drop position, or dragged records: invalid drop point
            if (!(targetNode && position && dataLength)) {
                return false;
            }

            // If the targetNode is within the folder we are dragging
            for (i = 0; i < ln; i++) {
                record = draggedRecords[i];
                if (record.isNode && record.contains(targetNode)) {
                    return false;
                }
            }

            // Respect the allowDrop field on Tree nodes
            if (position === 'append' && targetNode.get('allowDrop') === false) {
                return false;
            }
            else if (position !== 'append' && targetNode.parentNode.get('allowDrop') === false) {
                return false;
            }

            // If the target record is in the dragged dataset, then invalid drop
            if (Ext.Array.contains(draggedRecords, targetNode)) {
                 return false;
            }

            // @TODO: fire some event to notify that there is a valid drop possible for the node you're dragging
            // Yes: this.fireViewEvent(blah....) fires an event through the owning View.
            return true;
        };
    },

    /**
     * Ask for confirmation before the node drop
     */
    beforeDrop: function(node, data, overModel, dropPosition, dropHandlers) {
        var agreeCopyId, agreeDropId, msg, same,
        view = this.getTreeView(),
        orig = data.records[0];
        dropHandlers.wait = true;

        //get agreement id of copied record
        agreeCopyId = view.getAgreementId(orig);
        //get agreement id of drop target
        agreeDropId = view.getAgreementId(overModel);

        if(same = (agreeCopyId === agreeDropId)) {
            msg = 'Are you sure you want to copy this Deliverable? <br/>'+
                'The original will be cancelled.';
        } else{
            msg = 'Create a copy of the deliverable?';
        }

        Ext.MessageBox.confirm(
            'Confirm',
            msg,
            function(btn) {
                var tab, origRec, dropRec, newRec;

                if (btn === 'yes') {
                    if(same) {
                        tab = view.up('tabpanel');
                        origRec = tab.down('deliverableform #itemForm').getRecord();
                        tab.getEl().mask('Processing...');
                        newRec = origRec.copy(); //clone
                        Ext.data.Model.id(newRec); //generate a unique sequential id

                        //TODO: need to validate record is the same as ref in tree?
                        orig.set('invalid', true);//invalidate the original tree record
                        orig.set('readonly', true); //lock the original tree record

                        view.addRowCls(orig,'pts-deliverable-invalid'); //visually invalidate node
                        //edit new record
                        newRec.beginEdit();
                        newRec.phantom = true;
                        newRec.data.id = null;
                        newRec.set('deliverableid', null);
                        newRec.set('modificationid', view.getDataId(overModel, 60));
                        newRec.set('invalid', false);
                        newRec.set('parentmodificationid', origRec.get('modificationid'));
                        newRec.set('parentdeliverableid', origRec.get('deliverableid'));
                        newRec.endEdit();

                        //save the new rec, process the drop on success
                        newRec.save({
                            success: function(model, op) {
                                var processed,newnode,
                                    newRec = op.records[0],
                                    delid = newRec.get('deliverableid'),
                                    modid = newRec.get('modificationid');
                                //update the dropped node
                                dropRec = orig.copy();
                                dropRec.setId('d-'+ delid + '-' + modid);
                                dropRec.set('dataid',modid + '/deliverable/' + delid);
                                dropRec.set('invalid',false);
                                dropRec.set('readonly',false);
                                dropRec.set('cls','');
                                dropRec.set('parentItm','d-'+ origRec.get('deliverableid') + '-' + origRec.get('modificationid'));
                                dropRec.set('iconCls','pts-page-bluecopy');

                                processed = dropHandlers.processDrop([dropRec]); //process updated record
                                newnode = view.getNode(processed.records[0]);//assumes 1 record
                                view.getSelectionModel().select(view.getTreeStore().getNodeById(newnode.id));//select first dropped record
                                tab.getEl().unmask();
                            },
                            failure: function(model, op) {
                                Ext.MessageBox.show({
                                   title: 'Error',
                                   msg: 'Could not update the new deliverable.</br>Error:' + PTS.app.getError(),
                                   buttons: Ext.MessageBox.OK,
                                   //animateTarget: 'mb9',
                                   icon: Ext.Msg.ERROR
                                });
                                tab.getEl().unmask();
                            },
                            scope: this
                        });
                    }else {//else just create a copy
                        //we can drop into an "agreement" or a "modification"
                        var dataid = view.getDataId(overModel, 60) || view.getDataId(overModel, 20);
                        tab = view.up('tabpanel');
                        origRec = tab.down('deliverableform #itemForm').getRecord();
                        tab.getEl().mask('Processing...');
                        newRec = origRec.copy(); //clone
                        Ext.data.Model.id(newRec); //generate a unique sequential id

                        //edit new record
                        newRec.beginEdit();
                        newRec.phantom = true;
                        newRec.data.id = null;
                        newRec.set('deliverableid', null);
                        newRec.set('modificationid', dataid);
                        newRec.set('invalid', false);
                        newRec.endEdit();

                        //save the new rec, process the drop on success
                        newRec.save({
                            success: function(model, op) {
                                var processed,newnode,
                                    newRec = op.records[0],
                                    delid = newRec.get('deliverableid'),
                                    modid = newRec.get('modificationid');
                                //update the dropped node
                                dropRec = orig.copy();
                                dropRec.setId('d-'+ delid + '-' + modid);
                                dropRec.set('dataid',modid + '/deliverable/' + delid);
                                dropRec.set('invalid',false);
                                dropRec.set('readonly',false);
                                dropRec.set('cls','');

                                processed = dropHandlers.processDrop([dropRec]); //process updated record
                                newnode = view.getNode(processed.records[0]);//assumes 1 record
                                view.getSelectionModel().select(view.getTreeStore().getNodeById(newnode.id));//select first dropped record
                                tab.getEl().unmask();
                            },
                            failure: function(model, op) {
                                Ext.MessageBox.show({
                                   title: 'Error',
                                   msg: 'Could not update the new deliverable.</br>Error:' + PTS.app.getError(),
                                   buttons: Ext.MessageBox.OK,
                                   //animateTarget: 'mb9',
                                   //fn: showResult,
                                   icon: Ext.Msg.ERROR
                                });
                                tab.getEl().unmask();
                            },
                            scope: this
                        });
                    }
                } else {
                    dropHandlers.cancelDrop();
                }
             },
             this
        );
    },

    /**
     * Expand all nodes
     */
    expandAll: function(b, ev) {
        var owner = b.ownerCt;

        owner.child('tool[type=collapse]').show();
        b.hide();
        owner.up('treepanel').collapseAll();//hack to make all nodes expand
        owner.up('treepanel').expandAll();
    },

    /**
     * Collapse all nodes
     */
    collapseAll: function(b, ev) {
        var owner = b.ownerCt;

        owner.child('tool[type=expand]').show();
        b.hide();
        owner.up('treepanel').collapseAll();
    },

    /**
     * Refresh tree store
     * TODO: Fire app refresh event to update itemdetail, buttons
     */
    refresh: function(b, ev) {
        var owner = b.ownerCt,
        detail = this.getItemDetail(),
        store=owner.up('treepanel').getStore();

        //set the itemdetail panel to first card
        //TODO: this should trigger the check status function
        //and give the user the option to halt
        detail.getLayout().setActiveItem(0);
        owner.up('projectagreements').down('#rootBtn').show();
        //TODO: set appropriate title and icon
        detail.setTitle('Detail');
        detail.setIconCls('x-tree-icon-parent');

        //hack to stop posting of removed nodes
        //TODO: Fixed in 4.1
        //http://www.sencha.com/forum/showthread.php?151211
        store.getRootNode().removeAll();
        store.load();
    },

    /**
     * Clear tree store
     */
    clear: function() {
        var store = this.getAgreementsTreeStore();

        //hack to stop posting of removed nodes
        //TODO: Fixed in 4.1
        //http://www.sencha.com/forum/showthread.php?151211
        store.getRootNode().removeAll();
        //store.removeAll();
    },

    /**
     * Close project event
     */
    onCloseProject: function() {
        this.clear();
    }
});
