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
    /*controllers: [
        'project.window.Window'
    ],*/

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
        var win, code,
            id = record ? record.get('projectid') : false;

        if(id !== false) {
            code = record.getProjectCode();

            win = Ext.create(this.getProjectWindowWindowView(),{
                title: 'Edit Project: ' + code,
                projectId: id
            });
        } else{
            win = Ext.create(this.getProjectWindowWindowView(),{
                title: 'New Project'
            });
            //disable all tabs except projectform
            win.down('#projecttabpanel').items.each(function() {
                if('projectform' !== this.getXType()) {
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
            if('projectform' !== this.getXType()) {
                this.enable();
            }
        });
    }
});
