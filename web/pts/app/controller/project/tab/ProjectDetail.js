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
        selector: 'projectdetail > projectagreements'
    }],

    init: function() {

       /*this.control({
            'projectlist': {
                itemdblclick: this.editProject,
                viewready: this.onProjectDetailReady,
                selectionchange: this.onProjectDetailSelect
            }
        });*/

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
                    'short': true
                },
                reader: {
                    type: 'json'
                }
            },
            treeStore = this.getProjectAgreementsTreeStore();

            treeStore.setProxy(treeProxy);
            //load the store
            treeStore.load();
    }
});
