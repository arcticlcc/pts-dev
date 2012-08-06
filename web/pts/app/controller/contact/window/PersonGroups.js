/**
 * The PersonGroups controller
 */
Ext.define('PTS.controller.contact.window.PersonGroups', {
    extend: 'Ext.app.Controller',
    requires: [
        'PTS.view.controls.ReorderColumn'
    ],
    views: [
        'contact.window.PersonGroups'
    ],
    models: [
        'ContactContactGroup'
    ],
    stores: [
        'ContactGroups',
        'DDContactGroups',
        'ContactContactGroups',
        'Persons',
        'Positions',
        'DDPersons'
    ],
    refs: [{
        ref: 'personGroups',
        selector: 'persongroups'
    },{
        ref: 'contactLists',
        selector: 'persongroups #contactLists'
    },{
        ref: 'groupMembersList',
        selector: 'persongroups #groupMembersList'
    }],

    init: function() {

        /*var list = this.getController('project.tab.ProjectList')

        // Remember to call the init method manually
        list.init();*/



        this.control({
            'persongroups': {
                afterrender: this.afterRender
            },
            'persongroups button[action=addcontacts]': {
                click: this.addContacts
            },
            'persongroups button[action=removecontacts]': {
                click: this.removeContacts
            },
            'persongroups button[action=savecontacts]': {
                click: this.saveContacts
            },
            'persongroups button[action=refreshcontacts]': {
                click: this.refreshContacts
            },
            'persongroups #contactLists > gridpanel': {
                beforerender: this.beforeRenderContactLists
            },
            'persongroups #contactLists > gridpanel > gridview': {
                beforedrop: this.removeContactsByDrag
            },
            'persongroups #groupMembersList > gridview': {
                afterrender: this.afterRenderGroupMembersList
            },
            'persongroups #groupMembersList': {
                beforerender: this.beforeRenderGroupMembersList
            }
        });

        // We listen for the application-wide events
        this.application.on({
            opencontact: this.onOpenContact,
            savecontact: this.onSaveContact,
            scope: this
        });
    },

    /**
     * @cfg {String} contactType
     * Specifies the contact type. This determines which selection list is shown.
     */
    contactType: null,

    /**
     * @cfg {String} contactId
     * Specifies the contact id.
     */
    contactId: null,

    /**
     * @cfg {String} reorderCol
     * Specifies whether the reorder column is rendered.
     */
    reorderCol: true,

    /**
     * Set proxy based on current contactid.
     * @param {Number} contactid
     * @param {PTS.store.ContactContactGroups}
     * @param {String} type Type of contact
     *
     * - **person**
     * - **group**
     */
    setProxy: function(id, store, type) {
        var uri;

        switch(type) {
            case 'person':
                uri = '../person/' + id + '/group';
                break;
            case 'group':
                uri = '../contactgroup/' + id + '/member';
                break;
            default:
                Ext.Error.raise('Contact type not supplied!');
        }

        //override store proxy based on contactid
        store.setProxy({
            type: 'rest',
            url : '../contactcontactgroup',
            appendId: true,
            //batchActions: true,
            api: {
                read: uri,
                create: uri,
                update: uri
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
    },

    /**
     * Open contact event.
     */
    onOpenContact: function(id, type) {
        var store = this.getContactContactGroupsStore();

        if(id) {
            this.setProxy(id, store, type);
            //load the ContactContactGroups store
            store.load();
        }

        this.contactType = type;
        this.reorderCol = type === 'group' ? false : this.reorderCol;
        this.contactId = id;
    },

    /**
     * Save contact event.
     * TODO: Should we check to see if record is phantom first?
     */
    onSaveContact: function(record) {
        var store = this.getContactContactGroupsStore(),
            id = record.getId(),
            type = record.getContactType();

        if(id) {
            this.setProxy(id, store, type);
            this.contactId = id;
            //load the ContactContactGroups store
            store.load();
            this.getPersonGroups().enable();
        }
    },

    /**
     * Stuff to do after rendering the PersonGroups view.
     * The appropriate card is activated based on the contact type.
     * The contactlist store is loaded.
     */
    afterRender: function(panel) {
        var store,
            layout = this.getContactLists().getLayout();


        //activate the appropriate card
        switch(this.contactType) {
            case 'person':
                layout.setActiveItem(1);
                break;
            case 'group':
                layout.setActiveItem(0);
                //need to change the title for the members lists
                panel.down('#groupMembersList').setTitle('Group Members');
                break;
            default:
                Ext.Error.raise('Contact type not supplied! Cannot activate card.');
        }

        //make sure the contact list is loaded
        store = layout.getActiveItem().getStore();
        //load the contact list
        if (store.getCount() === 0) {
            store.load();
        }
    },

    /**
     * Configure extra columns, checkboxSelection.
     */
    beforeRenderContactLists: function(grid) {
        var column = Ext.create('Ext.grid.column.Column', grid.getSelectionModel().getHeaderConfig());
        grid.headerCt.insert(0, column);
    },

    /**
     * Configure extra columns, checkboxSelection and reorder.
     * Configure the store
     */
    beforeRenderGroupMembersList: function(grid) {
        var order,
            column = Ext.create('Ext.grid.column.Column', grid.getSelectionModel().getHeaderConfig()),
            headerCt = grid.headerCt;

        headerCt.insert(0, column);

        if(this.reorderCol) {
            order = headerCt.insert(headerCt.getColumnCount()+1, {xtype: 'reordercolumn'});
        }else {
            headerCt.items.each(function() {
                this.sortable = true;
            });
        }
    },

    /**
     * Configure GroupMembers ddplugin.
     */
    afterRenderGroupMembersList: function(view) {
        var plugin = view.getPlugin('contactsddplugin'),
        contactId = this.contactId,
        contactType = this.contactType,
        dropZone = plugin.dropZone;
        dropZone.handleNodeDrop = function(data, record, position) {
            var view = this.view,
                store = view.getStore(),
                //contactid = this.contactId,
                index, records, i, len;

            // If the copy flag is set, create a copy of the Models with unique IDs
            if (data.copy) {
                records = data.records;
                data.records = [];
                for (i = 0, len = records.length; i < len; i++) {
                    var copy = records[i].data,
                        rec, cfg;

                    //combine names for a person record
                    if(copy.name === undefined) {
                        copy.name = copy.lastname + ', ' + copy.firstname;
                    }
                    //create the new record, copying values from dropped record
                    //we need to handle contact types differently
                    switch(contactType) {
                        case 'person':
                            cfg = {
                                    'name': copy.name,
                                    'positionid': '',
                                    'groupid': copy.contactid,
                                    'contactid': contactId
                                };
                            break;
                        case 'group':
                            cfg = {
                                    'name': copy.name,
                                    'positionid': '',
                                    'groupid': contactId,
                                    'contactid': copy.contactid
                                };
                            break;
                        default:
                            Ext.Error.raise('Contact type not supplied!');
                    }

                    rec = Ext.create('PTS.model.ContactContactGroup',cfg);
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
    },

    /**
     * Remove contacts via drag/drop.
     */
     removeContactsByDrag: function(node, data, overModel, dropPosition, dropFunction) {
        this.getContactContactGroupsStore().remove(data.records);
        return false;
    },

    /**
     * Remove contacts action.
     */
     removeContacts: function(){
        var grid = this.getGroupMembersList(),
        sel = grid.getSelectionModel().getSelection();

        grid.getStore().remove(sel);
    },

    /**
     * Refresh contacts action.
     */
     refreshContacts: function(){
        var grid = this.getGroupMembersList();

        grid.getStore().load({
            callback: function(records, operation, success) {
                //hack to clear the removed records array
                grid.getStore().removed =[];
            }
        });
    },

    /**
     * Add contacts action.
     */
     addContacts: function(){
        var grid = this.getContactLists().getLayout().getActiveItem(),
        sel = grid.getSelectionModel().getSelection(),
        data = {//build data object
            copy: true,
            view: grid.getView(),
            records: sel
        },
        dz = this.getGroupMembersList().getView().getPlugin('contactsddplugin').dropZone;

        //use dropzone to add records
        dz.handleNodeDrop(data);
    },

    /**
     * Save contacts.
     */
     saveContacts: function() {
        var store = this.getContactContactGroupsStore(),
            el = this.getGroupMembersList().getEl();

        //loop thru records and set the priority
        if(this.reorderCol) {
            store.each(function() {
                var rec = this,
                    priority = rec.get('priority'),
                    idx  = store.indexOf(rec);

                if(priority !== idx) {
                    rec.set('priority', idx);
                }
            });
        }

        //mask panel if store is dirty
        if(!!(store.getRemovedRecords().length + store.getUpdatedRecords().length
                + store.getNewRecords().length)) {
            el.mask('Saving...');
        }
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
//console.log('Contacts saved');
                el.unmask();
            },
            failure: function() {
                el.unmask();
                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'The was a problem saving the contacts.</br>Error:' + PTS.app.getError(),
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   icon: Ext.Msg.ERROR
               });
            },
            callback: function() {

            }
        });
     }
});
