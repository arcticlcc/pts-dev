/**
 * Controller for ProjectAgreements
 */
Ext.define('PTS.controller.project.window.ProjectAgreements', {
    extend: 'Ext.app.Controller',

    views: [
        'project.window.ProjectAgreements'
    ],
    models: [
        'Modification'
    ],
    /*stores: [
        'ProjectAgreements',
        'ContactGroups',
        'Persons',
        'RoleTypes'
    ],*/
    refs: [{
        ref: 'agreementsTab',
        selector: 'projectagreements'
    }, {
        ref: 'agreementsTree',
        selector: 'agreementstree'
    }, {
        ref: 'itemDetail',
        selector: 'agreementitemdetail'
    }],

    init: function() {

        var tree = this.getController('project.window.AgreementsTree'),
            item = this.getController('project.window.ItemDetail');

        // Remember to call the init method manually
        tree.init();
        item.init();



        this.control({
            'projectagreements': {
                beforerender: this.onBeforeRender
            },
            'agreementstree': {
                select: this.onSelectItem
            },
            'agreementitemdetail': {
                beforerender: this.onBeforeRenderItemDetail
            },
            'agreementitemdetail #mainItemToolbar': {
                beforerender: this.onRenderItemToolbar
            }
            /*,
                        'projectcontacts button[action=addcontacts]': {
                            click: this.addContacts
                        }*/
        });

        // We listen for the application-wide openproject event
        /*this.application.on({
            openproject: this.onOpenProject,
            scope: this
        });*/
    },

    /**
     * New item button.
     */
    newItemBtn: Ext.create('Ext.Action', {
        itemId: 'newItemBtn',
        text: 'New',
        iconCls: 'pts-menu-addbasic',
        hidden: true,
        handler: function() {
            Ext.Msg.alert('Click', 'You clicked on "New".');
        },
        listeners: {
            show: function() {
                var rootBtn = this.ownerCt.child('#rootBtn');
                if (rootBtn) {
                    rootBtn.hide();
                }
            }
        }
    }),


    /**
     * Edit item action.
     */
    editItemBtn: Ext.create('Ext.Action', {
        itemId: 'editItemBtn',
        text: 'Edit',
        iconCls: 'pts-menu-editbasic',
        disabled: true,
        handler: function(b, e) {
            //TODO: set handler in event to avoid ComponentQuery, also save action
            var panel = Ext.ComponentQuery.query('projectagreements #itemDetail')[0],
                form = panel.getLayout().getActiveItem().child('#itemForm');

            panel.setIconCls('pts-panel-unlocked');
            Ext.each(form.query('field'), function() { // set fields as editable
                if (!this.doNotEnable) {
                    this.setReadOnly(false);
                } else {
                    this.getEl().setOpacity(0.5);
                }
            });

            Ext.each(Ext.ComponentQuery.query('#editItemBtn'), function() { //disable all instances of this action
                this.disable();
            });

            //Ext.getCmp('alcc-agreements-tab').actions.editItemBtn.disable(); //disable edit button

            //Ext.Msg.alert('Click', 'You clicked on "Edit".');
        }
    }),

    /**
     * Delete item action.
     */
    deleteItemBtn: Ext.create('Ext.Action', {
        itemId: 'deleteItemBtn',
        text: 'Delete',
        iconCls: 'pts-menu-deletebasic',
        disabled: true,
        handler: function() {
            var tab = Ext.ComponentQuery.query('projectagreements')[0],
                panel = tab.down('#itemDetail'),
                card = panel.getLayout().getActiveItem(),
                form = card.child('#itemForm').getForm(),
                del = function(b) {
                    if ('yes' === b) {
                        var record = form.getRecord(),
                            tree = tab.down('agreementstree'),
                            treeRecord = tree.getSelectionModel().getSelection()[0];
                        //newRecord = record.phantom;

                        //set mask
                        tab.getEl().mask('Deleting...');

                        record.destroy({
                            success: function(model, op) {
                                var pid = treeRecord.get('parentItm');

                                PTS.app.fireEvent('savedeliverable', op.records[0], op);

                                //select parent node
                                tree.getView().select(treeRecord.parentNode);
                                treeRecord.remove(true);
                                //if the record is a modification of another node
                                //check to see if the parent still has child mods
                                if (!!pid && !tree.getRootNode().findChild('parentItm', pid, true)) {
                                    tree.getStore().getNodeById(pid).set('readonly', false);
                                    //TODO: check parent node invalid class
                                }
                                tab.getEl().unmask();
                            },
                            failure: function(model, op) {
                                Ext.MessageBox.show({
                                    title: 'Error',
                                    msg: 'There was a problem deleting the record.</br>' + PTS.app.getError(),
                                    buttons: Ext.MessageBox.OK,
                                    animateTarget: panel.down('#deleteItemBtn').getEl(),
                                    fn: function() {
                                        tab.getEl().unmask();
                                    },
                                    icon: Ext.Msg.ERROR
                                });
                            }
                        });
                    }
                };

            if (card.ptsConfirmDelete === true) {
                Ext.MessageBox.show({
                    title: 'Confirm Deletion',
                    msg: 'Are you sure you want to delete this <b>' + card.title + '</b>?',
                    //width:300,
                    buttons: Ext.MessageBox.YESNO,
                    icon: Ext.Msg.WARNING,
                    fn: del,
                    animateTarget: panel.down('#deleteItemBtn').getEl()
                });
            } else {
                del('yes');
            }
        }
    }),


    /**
     * Reset item action.
     */
    resetItemBtn: Ext.create('Ext.Action', {
        itemId: 'resetItemBtn',
        text: 'Reset',
        iconCls: 'pts-menu-reset',
        disabled: true,
        handler: function(b) {
            var panel = b.up('panel'),
                form = panel.getLayout().getActiveItem().child('#itemForm').getForm();

            form.reset();
        }
    }),


    /**
     * Save item action.
     * //TODO: remove dependency on modtypeid, use card itemId???
     */
    saveItemBtn: Ext.create('Ext.Action', {
        itemId: 'saveItemBtn',
        text: 'Save',
        iconCls: 'pts-menu-savebasic',
        disabled: true,
        handler: function() {
            //Ext.Msg.alert('Click', 'You clicked on "Save".');
            var tab = Ext.ComponentQuery.query('projectagreements')[0],
                panel = tab.down('#itemDetail'),
                card = panel.getLayout().getActiveItem(),
                form = card.child('#itemForm').getForm(),
                record = form.getRecord(),
                tree = tab.down('agreementstree'),
                treeRecord = tree.getSelectionModel().getSelection()[0],
                newRecord = record.phantom;

            //set mask
            tab.getEl().mask('Saving...');
            form.updateRecord(record);

            record.save({
                success: function(model, op) {
                    var tNode, nNode, children, modChild,
                        title = model.get('title'),
                        itemid = card.itemId,
                        pNode;
                    //TODO: update title

                    if (Ext.getClassName(model) === 'PTS.model.Deliverable') {
                        PTS.app.fireEvent('savedeliverable', model, op);
                    }

                    if (Ext.getClassName(model) === 'PTS.model.Modification') {
                        PTS.app.fireEvent('savemodification', model, op, newRecord);
                    }

                    form.loadRecord(model); //load the model to get desired trackresetonload behaviour
                    //build node
                    tNode = {
                        text: title,
                        cls: model.get('invalid') ? 'pts-deliverable-invalid' : null, //based on model invalid field
                        leaf: true,
                        draggable: false,
                        dataid: model.getId()
                    };
                    //insert tree node
                    if (newRecord) {
                        //add parentcode
                        tNode.parentcode = model.get('parentcode');
                        //if item is a modification or agreement,  we need to add child branches
                        if (itemid === 'itemCard-20' || itemid === 'itemCard-60') {
                            children = [{
                                "children": [],
                                "text": "Deliverables",
                                "id": "df-" + model.getId(),
                                "iconCls": "task-folder",
                                "leaf": false,
                                "draggable": false,
                                "typeid": 30,
                                "fkey": {
                                    "modificationid": model.getId()
                                },
                                "defIcon": "pts-page-blue"
                            }, {
                                "children": [],
                                "text": "Funds",
                                "id": "ff-" + model.getId(),
                                "iconCls": "task-folder",
                                "leaf": false,
                                "draggable": false,
                                "typeid": 50,
                                "fkey": {
                                    "modificationid": model.getId()
                                },
                                "defIcon": "pts-money-dollar"
                            }, {
                                "children": [],
                                "text": "Tasks",
                                "id": "tf-" + model.getId(),
                                "iconCls": "task-folder",
                                "leaf": false,
                                "draggable": false,
                                "typeid": 40,
                                "fkey": {
                                    "modificationid": model.getId()
                                },
                                "defIcon": "pts-page-orange"
                            }];
                            //only add mod folder if new node is an agreement
                            if (!model.get('parentmodificationid')) {
                                modChild = {
                                    "children": [],
                                    "text": "Modifications",
                                    "parentcode": model.get('modificationcode'),
                                    "id": "mf-" + model.getId(),
                                    "iconCls": "task-folder",
                                    "leaf": false,
                                    "draggable": false,
                                    "typeid": 60,
                                    "fkey": {
                                        "projectid": model.get('projectid'),
                                        "modtypeid": model.get('modtypeid'),
                                        "parentmodificationid": model.getId()
                                    }
                                };

                                children.push(modChild);
                            }

                            tNode.children = children;
                            tNode.leaf = false;
                        }

                        if (!treeRecord) { //no node has been selected
                            //TODO: come up with someting better here
                            if (itemid === 'itemCard-10') { //proposal
                                treeRecord = tab.down('agreementstree').getStore().getNodeById('prt-0');
                            } else if (itemid === 'itemCard-20') { //agreement
                                treeRecord = tab.down('agreementstree').getStore().getNodeById('art-0');
                            } else {
                                //refresh tree, this should never happen
                                Ext.Error.raise('TreeRecord Not Set');
                            }
                        }

                        //add new node
                        if (!!treeRecord.get('dataid')) { //only "real" records have dataids
                            pNode = treeRecord.parentNode;
                            tNode.iconCls = pNode.get('defIcon'); //get from parent
                            nNode = pNode.appendChild(tNode);
                        } else { //else add child to this node, it's a branch
                            tNode.iconCls = treeRecord.get('defIcon');
                            nNode = treeRecord.appendChild(tNode);
                        }
                        //select new node
                        tree.getView().select(nNode);
                        //expand tree
                        tree.expandPath(nNode.getPath());
                    } else {
                        //TODO: update record, i.e. title,validity
                        //update parentcode for modification sub-folder node
                        pNode = treeRecord.findChild('text', 'Modifications');
                        if (pNode) {
                            pNode.set('parentcode', model.get('modificationcode'));
                        }
                    }


                    panel.setTitle(title);
                    tab.getEl().unmask();
                },
                failure: function(model, op) {
                    var ms,
                        tree = tab.down('agreementstree'),
                        treeRecord = tree.getSelectionModel().getSelection()[0];

                    if (treeRecord) {
                        ms = 'There was an error saving ' + treeRecord.get('text');
                    } else {
                        ms = 'There was an error saving the record';
                    }

                    /*Ext.MessageBox.show({
                       title: 'Error',
                       msg: ms + '.</br>Error:' + PTS.app.getError(),
                       buttons: Ext.MessageBox.OK,
                       //animateTarget: 'mb9',
                       icon: Ext.Msg.ERROR
                   });*/
                    Ext.create('widget.uxNotification', {
                        title: 'Error',
                        iconCls: 'ux-notification-icon-error',
                        html: ms + '.</br>Error:' + PTS.app.getError()
                    }).show();
                    tab.getEl().unmask();
                },
                scope: tab
            });
        }
    }),

    /**
     * Return item context menu.
     */
    getContextMenu: function() {
        var menu = Ext.create('Ext.menu.Menu', {
            //width: 100,
            //height: 100,
            margin: '0 0 10 0',
            items: [
                this.newItemBtn,
                this.editItemBtn,
                this.deleteItemBtn
            ]
        });

        return menu;
    },

    getNewItemBtnHandler: function(typeid, title, rec) {
        var ctrl = this,
            panel = ctrl.getItemDetail(),
            projectId = panel.up('projectwindow').projectId;

        return function() {
            var fkey, //vals,
                form = panel.down('#itemCard-' + typeid + ' #itemForm'),
                //basic = form.getForm(),
                model = Ext.create(form.model);

            panel.getLayout().setActiveItem('itemCard-' + typeid);

            //set fkeys
            if (rec) {
                fkey = rec.get('fkey') ? rec.get('fkey') : rec.parentNode.get('fkey');
                //vals = [];
                //create value objects array
                /*Ext.each(fkey, function(itm) {
                    if(itm[0]) {
                        vals.push({id: itm[1] , value: itm[0]});
                    }
                });*/
            } else { //no rec passed, so we assume root folder
                fkey = {
                    'projectid': projectId
                };
            }
            //set key values in model, do not fire update event
            model.beginEdit();
            model.set(fkey);
            model.endEdit(true);

            //load model and reset form
            form.loadRecord(model).reset();
            //fire newitem event
            ctrl.application.fireEvent('newitem', model, form);

            Ext.each(form.query('field'), function() { // set fields as writeable
                this.setReadOnly(false);
            });

            panel.setTitle(title);
            panel.setIconCls('pts-menu-addbasic');
            //panel.query('#editItemBtn, #deleteItemBtn');

            Ext.each(panel.query('#editItemBtn, #deleteItemBtn'), function() {
                this.disable();
            });

            panel.enable();

        };
    },

    getBtnConfig: function(typeid) {
        var icon = 'pts-menu-addbasic',
            cfg, txt;

        switch (typeid) {
            case 0:
                return false;
            case 10:
                txt = 'New Proposal';
                break;
            case 20:
                txt = 'New Agreement';
                break;
            case 30:
                txt = 'New Deliverable';
                break;
            case 40:
                txt = 'New Task';
                break;
            case 50:
                txt = 'New Funding';
                break;
            case 60:
                txt = 'New Modification';

                break;
            default:
                return false;

        }

        cfg = {
            iconCls: icon,
            text: txt
        };

        return cfg;
    },

    /*getNewItemBtn: function(typeid) {

        return item;
    },*/

    updateNewItemBtn: function(typeid, rec) {
        var item = this.newItemBtn,
            text = this.getBtnConfig(typeid).text,
            handler = this.getNewItemBtnHandler(typeid, text, rec);

        item.setText(text);
        item.setHandler(handler);
        item.enable();
        item.show();
    },

    /**
     * ProjectAgreements Tab beforerender listener.
     * Add main toolbar.
     */
    onBeforeRender: function(tab) {
        var newAgreement = this.getBtnConfig(20),
            newProposal = this.getBtnConfig(10);
        //assign handler
        newAgreement.handler = this.getNewItemBtnHandler(20, newAgreement.text);
        newProposal.handler = this.getNewItemBtnHandler(10, newProposal.text);

        tab.addDocked([{
            xtype: 'toolbar',
            dock: 'top',
            items: [{
                    xtype: 'button',
                    itemId: 'rootBtn',
                    text: 'New',
                    iconCls: 'pts-menu-add',
                    menu: {
                        xtype: 'menu',
                        items: [
                            newAgreement,
                            newProposal
                        ]
                    },
                    listeners: {
                        afterrender: function() { //apparently the show event does not fire after rendering
                            this.ownerCt.child('#newItemBtn').hide();
                        },
                        show: function() {
                            this.ownerCt.child('#newItemBtn').hide();
                        }
                    }
                },
                this.newItemBtn
            ]
        }]);
    },

    /**
     * ItemDetail beforerender listener.
     *
     */
    onBeforeRenderItemDetail: function(detail) {
        var me = this;

        detail.items.each(
            function(c) {
                var form = c.down('#itemForm');
                if (form) {
                    form.on({
                        dirtychange: {
                            fn: function(f, dirty) {
                                if (dirty) {
                                    this.resetItemBtn.enable();
                                    if (f.isValid()) {
                                        this.saveItemBtn.enable();
                                    }
                                } else {
                                    this.resetItemBtn.disable();
                                    this.saveItemBtn.disable();
                                }
                            },
                            scope: me
                        },
                        validitychange: {
                            fn: function(f, valid) {
                                if (valid && f.isDirty()) {
                                    this.saveItemBtn.enable();
                                } else {
                                    this.saveItemBtn.disable();
                                }
                            },
                            scope: me
                        }
                    });
                }
            },
            me
        );
    },

    /**
     * ItemDetail toolbar beforerender listener.
     * Add buttons to Item toolbar.
     */
    onRenderItemToolbar: function(tb) {
        tb.add([
            this.editItemBtn,
            this.deleteItemBtn,
            this.saveItemBtn,
            this.resetItemBtn
        ]);
    },

    /**
     * Select listener for agreements tree.
     */
    onSelectItem: function(rm, rec, index, opts) {
        var ctlr = this,
            typeid = rec.get('typeid'),
            id = rec.get('dataid'),
            parentItm = rec.get('parentItm'),
            readonly = !!rec.get('readonly'),
            tp = this.getAgreementsTab(),
            itemDetail = this.getItemDetail(),
            btns = [this.editItemBtn, this.deleteItemBtn],
            save = this.saveItemBtn,
            reset = this.resetItemBtn,
            view = this.getAgreementsTree().getView(),
            itemForm, itemCard;

        if (!typeid && id) {
            typeid = rec.parentNode.get('typeid'); //get type from parent
            itemCard = itemDetail.down('#itemCard-' + typeid); //get card for selected node
            itemForm = itemCard.down('#itemForm'); //get form for selected node

            //set mask
            itemDetail.getEl().mask('Loading...');
            //clear any filters on comboboxes
            Ext.each(itemForm.query('field'), function() {
                var me = this;

                if (me.isXType('combobox')) {
                    me.getStore().clearFilter();
                }
            });

            Ext.ModelMgr.getModel(itemForm.model).load(id, { // load with id from selected record
                success: function(model) {
                    itemForm.loadRecord(model); // when model is loaded successfully, load the data into the form
                    ctlr.application.fireEvent('itemload', model, itemForm); //fire itemloaded event

                    Ext.each(itemForm.query('field'), function() { // set all fields as read-only on load
                        this.setReadOnly(true);
                    });
                    itemDetail.setIconCls('pts-panel-locked'); //set the lock icon on the panel
                    //TODO: allow delete with warning about cascades.
                    //Will need to override the proxy for deliverables
                    Ext.each(btns, function() {
                        this.setDisabled(readonly);
                    });
                    itemDetail.getLayout().setActiveItem(itemCard);
                    if (itemForm.isXType('form')) {
                        if (itemForm.getForm().isDirty()) {
                            reset.enable();
                            if (itemForm.getForm().isValid()) {
                                save.enable();
                            }
                        } else {
                            reset.disable();
                            save.disable();
                        }
                    }

                    //if selected node is a deliverable mod,
                    //we hightlight the parent node
                    if (parentItm) {
                        var parentNode = view.getStore().getById(parentItm);
                        view.addRowCls(parentNode, 'pts-deliverable-highlight');
                        view.getSelectionModel().on('selectionchange', function(view, sel) {
                            this.removeRowCls(parentNode, 'pts-deliverable-highlight');
                        }, view, {
                            single: true
                        });
                    }

                    itemDetail.setTitle(rec.get('text') /*+ ": " + rec.get('task')*/ );
                    itemDetail.getEl().unmask();
                    itemDetail.enable();
                },
                failure: function(model, op) {
                    Ext.MessageBox.show({
                        title: 'Error',
                        msg: 'There was an error loading the record.</br>Error:' + PTS.app.getError(),
                        buttons: Ext.MessageBox.OK,
                        //animateTarget: 'mb9',
                        icon: Ext.Msg.ERROR
                    });
                    itemDetail.getEl().unmask();
                }
            });

        } else {
            Ext.each(btns, function() {
                this.disable();
            });
            itemDetail.getLayout().setActiveItem(0);
            //TODO: set appropriate title and icon
            itemDetail.setTitle(rec.get('text'));
            itemDetail.setIconCls('x-tree-icon-parent');
            //itemDetail.disable();
        }
        this.updateNewItemBtn(typeid, rec);
        tp.down('#rootBtn').hide();

    }
});
