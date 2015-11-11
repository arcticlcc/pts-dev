/**
 * Main Project controller
 */
Ext.define('PTS.controller.project.Project', {
    extend: 'Ext.app.Controller',
    requires: [
        'PTS.model.Modification',
        'PTS.model.Deliverable',
        'PTS.model.Funding'
    ],
    views: [
        /*'project.tab.ProjectTab',*/
        'project.window.Window'
    ],
    refs: [{
        ref: 'projectWindow',
        selector: 'projectwindow'
    }],
    stores: ['ProjectVectors'],

    init: function() {
        var tab = this.getController('project.tab.ProjectTab'),
            win = this.getController('project.window.Window');

        // Remember to call the init method manually
        tab.init();
        win.init();

        // We listen for the application-wide events
        this.application.on({
            saveproject: this.onSaveProject,
            scope: this
        });

    },

    /**
     * Creates and opens the project window.
     * @param {Object} [record] An optional project record.
     */
    openProject: function(record, callBack, animateTarget) {
        var win, code, cstore,
            id = record ? record.get('projectid') : false;

        if (id !== false) {
            code = record.getProjectCode();

            win = Ext.create(this.getProjectWindowWindowView(), {
                title: 'Edit Project: ' + code,
                projectId: id
            });
            //load the project comments
            cstore = win.down('#projecttabpanel>commenteditgrid').getStore();
            cstore.setProxy({
                type: 'rest',
                url: '../projectcomment',
                appendId: true,
                api: {
                    read: '../project/' + id + '/projectcomment'
                },
                reader: {
                    type: 'json',
                    root: 'data'
                }
            });
            cstore.load();
        } else {
            win = Ext.create(this.getProjectWindowWindowView(), {
                title: 'New Project'
            });
            //disable all tabs except projectform
            win.down('#projecttabpanel').items.each(function() {
                if ('projectform' !== this.getXType()) {
                    this.disable();
                }
            });

        }
        this.application.fireEvent('openproject', id);
        win.show(animateTarget, callBack);
    },

    /**
     * Save project event.
     * Enable all tab panels
     */
    onSaveProject: function(record) {
        var win = this.getProjectWindow();
        //TODO: we could check whether record is a phantom and not perform unnecessary enables
        //enable all tabs except projectform, which should already be enabled
        win.down('#projecttabpanel').items.each(function() {
            if ('projectform' !== this.getXType()) {
                this.enable();
            }
        });

        //TODO: put this in a separate controller
        //set the project comments proxy
        var cstore = win.down('#projecttabpanel>commenteditgrid').getStore();
        cstore.setProxy({
            type: 'rest',
            url: '../projectcomment',
            appendId: true,
            api: {
                read: '../project/' + record.getId() + '/projectcomment'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
        cstore.load();
    }
});
