/**
 * @class PTS.controller.dashboard.Dashboard
 */
Ext.define('PTS.controller.dashboard.Dashboard', {
    extend: 'Ext.app.Controller',
    //requires: ['Extensible.Extensible'],

    views: [
        'dashboard.Dashboard',
        'dashboard.DeliverableList',
        'dashboard.TaskList'
    ],

    init: function() {

        var cal = this.getController('dashboard.Calendar'),
            task = this.getController('dashboard.TaskList'),
            del = this.getController('dashboard.DeliverableList');

        // Remember to call the init method manually
        cal.init();
        task.init();
        del.init();

        this.control({
            'dashboard tasklist': {
                itemdblclick: this.openProject
            },
            'dashboard deliverablelist': {
                itemdblclick: this.openProject
            }
        });
    },

    /**
     * Open the project window
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    openProject: function(view, rec) {
        var id = rec.getId(),
            modid = rec.get('modificationid'),
            callBack = function() {
                var win = this,
                    store = win.down('agreementstree').getStore(),
                    tab = win.down('projectagreements'),
                    setPath = function(store) {
                        var path = store.getNodeById("d-" + id + "-" + modid).getPath();
                        this.down('agreementstree').selectPath(path);
                        this.getEl().unmask();
                    };

                //Ext.getBody().unmask();
                win.getEl().mask('Loading...');
                win.down('tabpanel').setActiveTab(tab);

                if (store.getRootNode().hasChildNodes()) {
                    setPath(store);
                } else {
                    store.on('load', setPath, win, {
                        single: true
                    });
                }
            };
        //set the getProjectCode method, if it doesn't exist
        //we assume that the record contains the projectcode
        if (rec.getProjectCode === undefined) {
            rec.getProjectCode = function() {
                return rec.get('projectcode');
            };
        }

        this.getController('project.Project').openProject(rec, callBack);
    }
});
