/**
 * Controller for ProjectList
 */
Ext.define('PTS.controller.project.tab.ProjectList', {
    extend: 'Ext.app.Controller',
    stores: [
        'ProjectListings'
    ],
    models: [
        'ProjectListing'
    ],
    views: [
        'project.tab.ProjectList'
    ],
    refs: [{
        ref: 'projectList',
        selector: 'projecttab > projectlist'
    }],

    init: function() {

        this.control({
            'projectlist': {
                itemdblclick: this.editProject,
                viewready: this.onProjectListReady,
                select: this.onProjectListSelect
            }
        });

        // We listen for the application-wide events
        this.application.on({
            saveproject: this.onSaveProject,
            deleteproject: this.onDeleteProject,
            scope: this
        });
    },

    editProject: function(grid, record) {
        var pc = this.getController('project.Project');

        pc.openProject(record);
    },

    onProjectListReady: function(grid) {
        var store = grid.getStore();
        if (store) {
            store.on('load', function(store, records, success, oper) {
                if (store.count() > 0) {
                    this.getSelectionModel().select(0);
                }
            }, grid);
        }
        store.load();
    },

    onProjectListSelect: function(rowModel, record) {
        this.application.fireEvent('projectlistselect', record);
    },

    onSaveProject: function(record, op) {
        var index, copy,
            store = this.getProjectListingsStore(),
            model = this.getProjectListingModel(),
            id = record.getId();

        index = store.indexOfId(id);

        if (index === -1) {
            //The record is new, refresh to update the "related" fields
            copy = Ext.create(model);
            store.insert(0, copy);
        } else {
            //The record exists in the store, so copy the data
            //Note: this will only copy the "project" fields,
            //refresh to update the "related" fields
            copy = store.getAt(index);

        }

        copy.fields.each(function(field) {
            copy.set(field.name, record.get(field.name));
        });
        //set projectcode
        copy.set('projectcode', copy.getProjectCode());
        copy.commit();
    },

    /**
     * Fired when a project is deleted.
     * No record is passed(null), so we
     * need to use the operation records array
     */
    onDeleteProject: function(record, op) {
        var store = this.getProjectListingsStore();

        Ext.each(op.records, function(rec) {
            var id = rec.getId();

            store.remove(store.getById(id));
        });
    }
});
