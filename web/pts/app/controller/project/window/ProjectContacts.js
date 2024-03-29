/**
 * The ProjectContacts controller
 */
Ext.define('PTS.controller.project.window.ProjectContacts', {
    extend: 'Ext.app.Controller',
    requires: [
        'PTS.view.controls.ReorderColumn'
    ],

    views: [
        'project.window.ProjectContacts'
    ],
    models: [
        'ProjectContact'
    ],
    stores: [
        'ProjectContacts',
        'ContactGroups',
        'DDContactGroups',
        'Persons',
        'RoleTypes',
        'DDPersons'
    ],
    refs: [{
        ref: 'projectContacts',
        selector: 'projectcontacts'
    }, {
        ref: 'contactLists',
        selector: 'projectcontacts #contactLists'
    }, {
        ref: 'projectContactsList',
        selector: 'projectcontacts #projectContactsList'
    }],

    init: function() {

        /*var list = this.getController('project.tab.ProjectList')

        // Remember to call the init method manually
        list.init();*/



        this.control({
            'projectcontacts': {
                activate: this.activate
            },
            'projectcontacts button[action=addcontacts]': {
                click: this.addContacts
            },
            'projectcontacts button[action=removecontacts]': {
                click: this.removeContacts
            },
            'projectcontacts button[action=savecontacts]': {
                click: this.saveContacts
            },
            'projectcontacts button[action=refreshcontacts]': {
                click: this.refreshContacts
            },
            'projectcontacts #contactLists > gridpanel': {
                activate: this.activateList,
                beforerender: this.beforeRenderContactLists
            },
            'projectcontacts #contactLists > gridpanel > gridview': {
                beforedrop: this.removeContactsByDrag
            },
            'projectcontacts #projectContactsList > gridview': {
                afterrender: this.afterRenderProjectContactsList,
                drop: this.dropProjectContactsList
            },
            'projectcontacts #projectContactsList': {
                beforerender: this.beforeRenderProjectContactsList,
                edit: this.onEditRole
            },
            'combo[itemId=roletypeCbxProject]': {
                select: this.onSelectRoleType
            }
        });

        // We listen for the application-wide events
        this.application.on({
            openproject: this.onOpenProject,
            saveproject: this.onSaveProject,
            scope: this
        });
    },

    /**
     * Activate role editor on first record of dropped set.
     */
    dropProjectContactsList: function(node, recs) {
        var idx = this.getProjectContactsStore().indexOf(recs.records[0]),
            editor = this.getProjectContactsList().getPlugin('contactEditor');

        editor.startEditByPosition({
            row: idx,
            column: 2
        });
    },
    /**
     * Set proxy based on current projectid.
     * @param {Number} projectid
     * @param {PTS.store.ProjectContacts}
     */
    setProxy: function(id, store) {

        //override store proxy based on projectid
        store.setProxy({
            type: 'rest',
            url: PTS.baseURL + '/projectcontact',
            appendId: true,
            //batchActions: true,
            api: {
                read: PTS.baseURL + '/project/' + id + '/contacts'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
    },

    /**
     * Open project event.
     */
    onOpenProject: function(id) {
        var store = this.getProjectContactsStore();

        if (id) {
            this.setProxy(id, store);
            //load the projectcontacts store
            store.load();
        }
    },

    /**
     * Select roletype event.
     */
    onSelectRoleType: function(combo, rec) {
        //force editor to complete following selection
        this.getProjectContactsList().getPlugin('contactEditor').completeEdit();
    },

    /**
     * Set the notice and partner fields during roletype validation.
     */
    onEditRole: function(editor, e) {
        var rObj = {
                5: null,
                6: null,
                7: null,
                12: null,
                13: null
            },
            pObj = {
                4: null,
                10: null
            },
            rec = e.record;

        if (e.field === 'roletypeid') {
            if (typeof rObj[e.value] !== "undefined") {
                rec.set('reminder', true);
            } else {
                rec.set('reminder', false);
            }
        }

        if (e.field === 'roletypeid') {
            if (typeof pObj[e.value] !== "undefined" && rec.get('contactid') !== PTS.user.get('groupid')) {
                rec.set('partner', true);
            } else {
                rec.set('partner', false);
            }
        }
    },

    /**
     * Save project event.
     * TODO: Should we check to see if record is phantom first?
     */
    onSaveProject: function(record) {
        var store = this.getProjectContactsStore(),
            id = record.getId();

        if (id) {
            this.setProxy(id, store);
            //load the projectcontacts store
            store.load();
        }
    },

    /**
     * Stuff to do when Project Contacts tab is activated.
     */
    activate: function(tab) {

    },

    /**
     * Contact list tab activated.
     */
    activateList: function(grid) {
        var store = grid.getStore();

        //load the contact list
        if (store.getCount() === 0) {
            store.load();
        }
    },

    /**
     * Configure extra columns, checkboxSelection and reorder.
     */
    beforeRenderContactLists: function(grid) {
        var column = Ext.create('Ext.grid.column.Column', grid.getSelectionModel().getHeaderConfig());
        grid.headerCt.insert(0, column);
    },

    /**
     * Save contacts.
     */
    saveContacts: function() {
        var store = this.getProjectContactsStore(),
            el = this.getProjectContactsList().getEl(),
            isDirty = !!(store.getRemovedRecords().length + store.getUpdatedRecords().length +
                store.getNewRecords().length);

        if (store.findExact('roletypeid', null) === -1) {
            //mask panel
            if (isDirty) {
                el.mask('Saving...');
            }
            //loop thru records and set the priority
            store.each(function() {
                var rec = this,
                    priority = rec.get('priority'),
                    idx = store.indexOf(rec);

                if (priority !== idx) {
                    rec.set('priority', idx);
                }
            });

            //TODO: Fixed in 4.1?
            //the failure and callback function won't be called on HTTP exception,
            //we need to overload the getBatchListeners method and add exception
            //handling directly to the batch, onBatchException is not defined by default
            //http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
            store.getBatchListeners = function() {
                var me = store,
                    listeners = {
                        scope: me,
                        exception: function(batch, op) {
                            el.unmask();
                            //This just replaces the global error message box.
                            Ext.MessageBox.show({
                                title: 'Error',
                                msg: 'There was an error saving the contacts.</br>Error:' + PTS.app.getError(),
                                buttons: Ext.MessageBox.OK,
                                //animateTarget: 'mb9',
                                icon: Ext.Msg.ERROR
                            });

                            store.rejectChanges();
                        }
                    };

                if (me.batchUpdateMode == 'operation') {
                    listeners.operationcomplete = me.onBatchOperationComplete;
                } else {
                    listeners.complete = me.onBatchComplete;
                }

                return listeners;
            };

            store.sync({
                success: function() {
                    el.unmask();
                    PTS.app.fireEvent('syncprojectcontacts', store);
                    //console.log('Contacts saved');
                },
                failure: function() {
                    el.unmask();
                    Ext.MessageBox.show({
                        title: 'Error',
                        msg: 'There was an error saving the contacts.</br>Error:' + PTS.app.getError(),
                        buttons: Ext.MessageBox.OK,
                        //animateTarget: 'mb9',
                        icon: Ext.Msg.ERROR
                    });
                },
                callback: function() {

                }
            });
        } else {
            PTS.app.showError('All contacts must be assigned a role before saving.');
        }
    },

    /**
     * Remove contacts action.
     */
    removeContacts: function() {
        var grid = this.getProjectContactsList(),
            sel = grid.getSelectionModel().getSelection();

        grid.getStore().remove(sel);
    },

    /**
     * Refresh contacts action.
     */
    refreshContacts: function() {
        var grid = this.getProjectContactsList();

        grid.getStore().load({
            callback: function(records, operation, success) {
                //hack to clear the removed records array
                grid.getStore().removed = [];
            }
        });
    },

    /**
     * Add contacts action.
     */
    addContacts: function() {
        var grid = this.getContactLists().getActiveTab(),
            sel = grid.getSelectionModel().getSelection(),
            data = { //build data object
                copy: true,
                view: grid.getView(),
                records: sel
            },
            pcGrid = this.getProjectContactsList(),
            dz = pcGrid.getView().getPlugin('contactsddplugin').dropZone;

        //use dropzone to add records
        dz.handleNodeDrop(data);
        //fire drop event
        pcGrid.getView().fireEvent('drop', null, data, null, null);
    },

    /**
     * Remove contacts via drag/drop.
     */
    removeContactsByDrag: function(node, data, overModel, dropPosition, dropFunction) {
        this.getProjectContactsStore().remove(data.records);
        return false;
    },

    /**
     * Configure extra columns, checkboxSelection and reorder.
     * Configure the store
     */
    beforeRenderProjectContactsList: function(grid) {
        var column = Ext.create('Ext.grid.column.Column', grid.getSelectionModel().getHeaderConfig());

        grid.headerCt.insert(0, column);
        grid.headerCt.insert(grid.headerCt.getColumnCount() + 1, {
            xtype: 'reordercolumn'
        });
    },

    /**
     * Configure projectcontacts ddplugin.
     */
    afterRenderProjectContactsList: function(view) {
        var plugin = view.getPlugin('contactsddplugin'),
            dropZone = plugin.dropZone;
        dropZone.handleNodeDrop = function(data, record, position) {
            var view = this.view,
                store = view.getStore(),
                projectid = view.up('projectwindow').projectId,
                index, records, i, len;

            // If the copy flag is set, create a copy of the Models with unique IDs
            if (data.copy) {
                records = data.records;
                data.records = [];
                for (i = 0, len = records.length; i < len; i++) {
                    var copy = records[i].data;

                    //combine names for a person record
                    if (copy.name === undefined) {
                        copy.name = copy.lastname + ', ' + copy.firstname;
                    }
                    //create the new record, copying values from dropped record
                    var rec = Ext.create('PTS.model.ProjectContact', {
                        'name': copy.name,
                        'roletypeid': '',
                        'contactid': copy.contactid,
                        'projectid': projectid,
                        'partner': false
                    });
                    // mark it as phantom since it doesn't exist in the serverside database
                    rec.phantom = true;
                    data.records.push(rec);
                }
                data.view.getSelectionModel().deselect(records);
            } else {
                /*
                 * Remove from the source store. We do this regardless of whether the store
                 * is the same because the store currently doesn't handle moving records
                 * within the store. In the future it should be possible to do this.
                 * Here was pass the isMove parameter if we're moving to the same view.
                 */
                data.view.store.remove(data.records, data.view === view);
            }

            index = store.indexOf(record);

            // 'after', or undefined (meaning a drop at index -1 on an empty View)...
            if (position !== 'before') {
                index++;
            }
            store.insert(index, data.records);
            view.getSelectionModel().select(data.records);
        };
    }
});
