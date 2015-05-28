/**
 * The ProjectMetadata controller
 */
Ext.define('PTS.controller.project.window.ProjectMetadata', {
    extend: 'Ext.app.Controller',
    requires: [],

    views: ['project.window.ProjectMetadata'],
    models: ['Project', 'ProjectMetadata'],
    stores: ['TopicCategories','UserTypes','ProjectCategories'],
    refs: [{
        ref: 'projectMetadata',
        selector: 'projectmetadata'
    },{
        ref: 'metadataForm',
        selector: 'projectmetadata metadataform'
    }, {
        ref: 'metadataPreview',
        selector: 'projectmetadata #metadataPreview'
    }],

    init: function() {

        /*var md = this.getController('project.form.MetadataForm')

         // Remember to call the init method manually
         md.init();*/

        this.control({
            'projectmetadata': {
                activate: this.activate
            },
            'projectmetadata button[action=goback]': {
                click: this.clickBack
            },
            'projectmetadata button[action=openpreview]': {
                click: this.openPreview
            },
            'projectmetadata button[action=json]': {
                click: this.clickPreview
            },
            'projectmetadata button[action=xml]': {
                click: this.clickPreview
            },
            'projectmetadata button[action=html]': {
                click: this.clickPreview
            },
            'projectmetadata button[action=reset]': {
                click: this.clickReset
            },
            'projectmetadata button[action=save]': {
                click: this.clickSave
            },
            'projectmetadata #publishBtn': {
                change: this.publish
            },
            'projectmetadata metadataform': {
                //broken in 4.0.7
                //dirtychange: this.onDirtyChange,
                validitychange: this.onValidityChange
            }
        });

        // We listen for the application-wide events
        this.application.on({
            //openproject: this.onOpenProject,
            loadproject: this.onLoadProject,
            saveproject: this.onLoadProject,
            scope: this
        });
    },

    /**
     * Set proxy based on current projectid.
     * @param {Number} projectid
     * @param {PTS.store.ProjectContacts}
     */
    /*setProxy: function(id,store) {

    //override store proxy based on projectid
    store.setProxy({
    type: 'rest',
    url : '../project',
    appendId: true,
    //batchActions: true,
    api: {
    read:'../project/' + id + '/'
    },
    reader: {
    type: 'json',
    root: 'data'
    }
    });
    },*/

    /**
     * Open project event.
     */
    /*onOpenProject: function(id) {
    var store = this.getProjectContactsStore();

    if(id) {
    this.setProxy(id, store);
    //load the projectmetadata store
    store.load();
    }
    },*/

    /**
     * Handle metadataform validity change event.
     */
    onValidityChange: function(form,valid) {
        var saveBtn = this.getProjectMetadata().down('button[action=save]');

        if (valid /*&& form.isDirty()*/) {//dirtychange not working with itemselector in 4.0.7
            saveBtn.enable();
        } else {
            saveBtn.disable();
        }
    },

    /**
     * Handle metadataform dirty change event.
     */
    onDirtyChange: function(form,dirty) {
        var saveBtn = this.getProjectMetadata().down('button[action=save]'),
            resetBtn = this.getProjectMetadata().down('button[action=reset]');

        if (dirty) { //boxselect always reports as dirty after change in 4.0.7
            resetBtn.enable();
            if (form.isValid()) {
                saveBtn.enable();
            }
        } else {
            resetBtn.disable(); //dirtychange not working with itemselector in 4.0.7
            saveBtn.disable();
        }
    },

    /**
     * Load project event.
     */
    onLoadProject: function(record) {
        var idx = !!(record.get('exportmetadata')) ? 1 : 0,
            btn = this.getProjectMetadata().down('#publishBtn'),
            items = btn.menu.items,
            id = record.get('projectid'),
            model = this.getProjectMetadataModel(),
            form = this.getMetadataForm();

        btn.setActiveItem(items.get(idx), true);

        form.setLoading(true, true);

        model.load(id, {// load with id from project record
            success: function(model) {
                form.loadRecord(model);
            }
        });

    },

    /**
     * Save project event.
     */
    /*onSaveProject: function(record) {
    var store = this.getProjectContactsStore(),
    id = record.getId();

    if(id) {
    this.setProxy(id, store);
    //load the projectmetadata store
    store.load();
    }
    },*/

    /**
     * Stuff to do when Project Metadata tab is activated.
     */
    activate: function(tab) {

    },

    /**
     * Reset button click handler.
     */
    clickReset: function(btn) {
        this.getMetadataForm().getForm().reset();
    },

    /**
     * Save button click handler.
     */
    clickSave: function(btn) {
        var form = this.getMetadataForm().getForm(),
            el = this.getMetadataForm().getEl(),
            record = form.getRecord();

        el.mask('Saving...');
        form.updateRecord(record);
        record.save({
            success: function(model, op) {
                var form = this.getMetadataForm();

                //load the model to get desired trackresetonload behavior
                form.loadRecord(model);
                el.unmask();
            },
            failure: function(model, op) {
                el.unmask();
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'There was an error saving the project metadata.</br>Error: ' + PTS.app.getError()
                }).show();
            },
            scope: this
        });
    },

    /**
     * Back button click handler.
     */
    clickBack: function(btn) {
        this.getProjectMetadata().getLayout().setActiveItem(0);
    },

    /**
     * Preview button click handler.
     */
    clickPreview: function(btn) {
        var prev = this.getMetadataPreview(),
            el = prev.getEl(),
            id = prev.up('projectwindow').projectId,
            tab = this.getProjectMetadata(),
            layout = tab.getLayout(),
            openBtn = tab.down('button[action=openpreview]');

        layout.setActiveItem(1);
        layout.getActiveItem().body.scrollTo('top',0);
        el.mask('Generating Preview...');
        //set the preview type
        openBtn.previewType = btn.action;

        el.child('code').load({
            url: '/project/' + id + '/metadata.' + btn.action + '?pretty=1',
            renderer: function(loader, resp) {
                loader.getTarget().update(hljs.highlight(btn.action, resp.responseText).value);
                el.unmask();
            }
        });
    },

    /**
     * Open preview button click handler.
     */
    openPreview: function(btn) {
        var id = btn.up('projectwindow').projectId;

        window.open('/project/' + id + '/metadata.' + btn.previewType + '?pretty=1', '_blank', null, true);
    },

    /**
     * Publish button click handler.
     */
    publish: function(btn) {
        var win = btn.up('projectwindow'),
            record = win.down('projectform').getForm().getRecord(),
            action = btn.getActiveItem().action,
            id = win.projectId;

        btn.disable();

        Ext.Ajax.request({
            url: '/project/' + id + '/metadata/publish',
            method: action,
            success: function(response, opts) {
                record.set('exportmetadata', action === 'DELETE' ? 0 : 1);
                record.save({
                    failure: function(model, op) {
                        Ext.create('widget.uxNotification', {
                            title: 'Error',
                            iconCls: 'ux-notification-icon-error',
                            html: 'The metadata was ' + action === 'DELETE' ? 'unpublished' : 'published. ' +
                                'However, there was an error saving the project.</br>Error:' + PTS.app.getError()
                        }).show();
                    }
                });

            },
            failure: function(response) {
                var items = btn.menu.items;
                //reset the button
                btn.setActiveItem(items.get(action === 'DELETE' ? 1 : 0), true);
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'There was an error publishing the metadata.</br>Error:' + PTS.app.getError()
                }).show();
            },
            callback: function(response, opts) {
                btn.enable();
            }
        });

    }
});
