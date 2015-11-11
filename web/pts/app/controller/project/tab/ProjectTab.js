/**
 * Controller for ProjectTab
 */
Ext.define('PTS.controller.project.tab.ProjectTab', {
    extend: 'Ext.app.Controller',

    views: [
        'project.tab.ProjectTab'
    ],

    refs: [{
        ref: 'projectList',
        selector: 'projecttab > projectlist'
    }, {
        ref: 'projectTab',
        selector: 'projecttab'
    }],

    init: function() {

        var list = this.getController('project.tab.ProjectList'),
            det = this.getController('project.tab.ProjectDetail');

        // Remember to call the init method manually
        list.init();
        det.init();

        this.control({
            'projecttab button[action=addproject]': {
                click: this.newProject
            },

            'projecttab button[action=editproject]': {
                click: this.editProject
            }
        });

        // We listen for the application-wide projectlistselect event
        this.application.on({
            projectlistselect: this.onProjectListSelect,
            scope: this
        });
    },

    newProject: function() {
        var pc = this.getController('project.Project');
        pc.openProject();
    },

    editProject: function() {
        var pc = this.getController('project.Project'),
            record = this.getProjectList().getSelectionModel().getSelection()[0];
        if (record) {
            pc.openProject(record);
        }
    },

    onProjectListSelect: function(prj) {
        this.getProjectTab().down('button[action=editproject]').setDisabled(!prj);
    }
});
