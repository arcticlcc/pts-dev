/**
 * Project Form controller.
 */
Ext.define('PTS.controller.project.form.ProjectForm', {
    extend: 'Ext.app.Controller',
    mixins: {
        fixQuery: 'PTS.util.mixin.FixRemoteQuery'
    },

    views: [
        'project.form.ProjectForm'
    ],
    models: [
        'Project'
    ],
    stores: [
        'ProjectIDs'
    ],
    refs: [{
        ref: 'projectForm',
        selector: 'projectform'
    }],

    init: function() {

        /*var list = this.getController('project.tab.ProjectList')

        // Remember to call the init method manually
        list.init();*/

        this.control({
            'projectform button[action=saveproject]': {
                click: this.saveProject
            },
            'projectform button[action=resetproject]': {
                click: this.resetProject
            },
            'projectform button[action=deleteproject]': {
                click: this.confirmDelete
            },
            'projectform combobox[queryMode=remote]': {
                beforequery: this.fixRemoteQuery
            }
        });

        // We listen for the application-wide openproject event
        this.application.on({
            openproject: this.onOpenProject,
            scope: this
        });
    },

    /**
     * Open project event.
     * TODO: filter parent projectlist to remove current project
     */
    onOpenProject: function(id) {
        this.loadRecord(id);
    },

    /**
     * Load project event.
     */
    onLoadProject: function(record) {
        this.application.fireEvent('loadproject', record);
    },

    /**
     * Save project event.
     */
    onSaveProject: function(record, op) {
        this.application.fireEvent('saveproject', record, op);
    },

    /**
     * Delete project event.
     */
    onDeleteProject: function(record, op) {
        this.application.fireEvent('deleteproject', record, op);
    },

    //TODO: fire app events to relod project list, etc.
    /**
     * Save project.
     */
     saveProject: function() {
        var form = this.getProjectForm().getForm(),
            el = this.getProjectForm().getEl(),
            record = form.getRecord();

        el.mask('Saving...');
        form.updateRecord(record);
        record.save({
            success: function(model, op) {
                var form = this.getProjectForm();

                form.loadRecord(model); //load the model to get desired trackresetonload behaviour
                form.up('window').projectId = model.getId();
                el.unmask();

                this.onSaveProject(model, op);
            },
            failure: function(model, op) {
                el.unmask();
                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'There was an error saving the project.</br>Error:' + PTS.app.getError(),
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   //fn: showResult,
                   icon: Ext.Msg.ERROR
               });
            },
            scope: this //need the controller to load the model on success
        });
     },

    /**
     * Confirm project deletion.
     */
    confirmDelete: function(btn) {
        var el = btn.getEl(),
            del = function(b) {
                if('yes' === b) {
                    this.deleteProject();
                }
            };

        Ext.MessageBox.show({
            title: 'Confirm Deletion',
            msg: 'Are you sure you want to delete this project?',
            //width:300,
            buttons: Ext.MessageBox.YESNO,
            icon: Ext.Msg.WARNING,
            fn: del,
            scope: this,
            animateTarget: el
        });
    },

    /**
     * Delete project.
     */
     deleteProject: function() {
        var form = this.getProjectForm().getForm(),
            el = this.getProjectForm().getEl(),
            record = form.getRecord();

        el.mask('Deleting...');
        record.destroy({
            success: function(model, op) {
                el.unmask();
                this.onDeleteProject(model, op);
                this.getProjectForm().up('window').close();
            },
            failure: function(model, op) {
                el.unmask();
                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'There was an error deleting the project.</br>Error:' + PTS.app.getError(),
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   icon: Ext.Msg.ERROR
               });
            },
            scope: this //need the controller
        });
     },

    /**
     * Reset project form.
     */
     resetProject: function() {
        var form = this.getProjectForm().getForm();

        form.reset();
     },

    /**
     * Load project.
     */
    loadRecord: function(id) {
        var ctl = this,
            model = this.getProjectModel(),
            form = this.getProjectForm();

        if(id) {
            model.load(id, { // load with id from selected record
                success: function(model) {
                    form.loadRecord(model); // when model is loaded successfully, load the data into the form

                    /*Ext.each(itemCard.query('field'), function() {// set all fields as read-only on load
                        this.setReadOnly(true);
                    });
                    itemDetail.setIconCls('alcc-panel-locked');//set the lock icon on the panel

                    Ext.each(btns, function(){
                        this.enable();
                    });
                    itemDetail.getLayout().setActiveItem(itemCard);
                    if(itemCard.isXType('form')) {
                        //console.info(itemCard.xtype);
                        if(itemCard.getForm().isDirty()) {
                            reset.enable();
                            if(itemCard.getForm().isValid()) {
                                save.enable();
                            }
                        } else {
                            reset.disable();
                            save.disable();
                        }
                    }
                    itemDetail.setTitle(rec.get('type') + ": " + rec.get('task'));
                    itemDetail.enable();*/
                    ctl.onLoadProject(model);
                },
                failure: function(model, op) {
                    Ext.MessageBox.show({
                       title: 'Error',
                       msg: 'There was an error loading the project.</br>Error:' + PTS.app.getError(),
                       buttons: Ext.MessageBox.OK,
                       //animateTarget: 'mb9',
                       icon: Ext.Msg.ERROR
                   });
                }
            });
        } else{
            form.loadRecord(Ext.create(model));
            ctl.onLoadProject(form.getForm().getRecord());
        }
    }
});
