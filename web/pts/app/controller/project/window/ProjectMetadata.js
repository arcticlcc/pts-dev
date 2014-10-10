/**
 * The ProjectMetadata controller
 */
Ext.define('PTS.controller.project.window.ProjectMetadata', {
    extend: 'Ext.app.Controller',
    requires: [],

    views: ['project.window.ProjectMetadata'],
    models: ['Project'],
    stores: [],
    refs: [{
        ref: 'projectMetadata',
        selector: 'projectmetadata'
    }, {
        ref: 'metadataPreview',
        selector: 'projectmetadata #metadataPreview'
    }],

    init: function() {

        /*var list = this.getController('project.tab.ProjectList')

         // Remember to call the init method manually
         list.init();*/

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
            'projectmetadata #publishBtn': {
                change: this.publish
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
     * Load project event.
     */
    onLoadProject: function(record) {
        var idx = !!(record.get('exportmetadata')) ? 1 : 0, btn = this.getProjectMetadata().down('#publishBtn'), items = btn.menu.items;

        btn.setActiveItem(items.get(idx), true);
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
            openBtn = tab.down('button[action=openpreview]');

        tab.getLayout().setActiveItem(1);
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
                            html: 'There was an error saving the project.</br>Error:' + PTS.app.getError()
                        }).show();
                    }
                });

            },
            failure: function(response) {
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
