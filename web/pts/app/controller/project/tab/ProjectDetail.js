/**
 * Controller for ProjectDetail
 */
Ext.define('PTS.controller.project.tab.ProjectDetail', {
    extend: 'Ext.app.Controller',
    stores: [
        'ProjectAgreementsTree'
    ],
    models: [
        'AgreementsTree'
    ],
    views: [
        'project.tab.ProjectDetail'
    ],
    refs: [{
        ref: 'projectAgreements',
        selector: 'projectdetail > #projectAgreements'
    }],

    init: function() {

       this.control({
            'projectdetail > #projectAgreements': {
                beforeitemdblclick: this.onProjectAgreementsDblClick//,
                //itemclick: this.onProjectAgreementsClick
            }
        });

        // We listen for the application-wide events
        this.application.on({
            projectlistselect: this.onSelectProject,
            scope: this
        });
    },

    /**
     * Fired when a project is selected.
     */
    onSelectProject: function(record) {
        var id = record.getId(),
            treeProxy = {
                type: 'ajax',
                url : '../project/' + id + '/tree',
                extraParams: {
                    //'short': true
                },
                reader: {
                    type: 'json'
                }
            },
            treeStore = this.getProjectAgreementsTreeStore();

            treeStore.setProxy(treeProxy);
            //load the store
            treeStore.load();

            this.projectRecord = record;
    },

    /**
     * ProjectAgreements grid double click handler
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    onProjectAgreementsDblClick: function(view, rec) {
            //Ext.ComponentQuery.query('viewport')[0].getEl().mask();
            //console.info(Ext.ComponentQuery.query('viewport')[0].getEl().isMasked());
            this.openProject(rec.getPath());
            return false;
    },

    /**
     * ProjectAgreements grid click handler.
     * Expands the node on single click.
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    onProjectAgreementsClick: function(view, rec, el, idx, e) {
        var isExpanded = rec.isExpanded();
            console.info(arguments);
        //If the node is expandable and it is currently expanded then collapse otherwise expand
        if(!rec.collapsing && rec.isExpanded()) {
            rec.collapse();
        }else if(!rec.isExpanded()) {
            rec.expand();
        }
    },

    /**
     * Open the project window
     * @param {string} path The path to expand in the {@link PTS.view.project.window.AgreementsTree AgreementsTree}.
     */
    openProject: function(path) {
        var callBack = function() {
            var win = this,
                store = win.down('agreementstree').getStore(),
                tab = win.down('projectagreements'),
                setPath = function(store) {
                    this.down('agreementstree').selectPath(path);
                    this.getEl().unmask();
                };

            //Ext.getBody().unmask();
            win.getEl().mask('Loading...');
            win.down('tabpanel').setActiveTab(tab);

            if(store.getRootNode().hasChildNodes()) {
                setPath(store);
            }else {
                store.on('load', setPath, win, {
                    single: true
                });
            }
        };
        //set the getProjectCode method, if it doesn't exist
        //we assume that the record contains the projectcode
        /*if(rec.getProjectCode === undefined) {
            rec.getProjectCode = function() {
                return rec.get('projectcode');
            };
        }*/

        this.getController('project.Project').openProject(this.projectRecord, callBack);
    }
});
