/**
 * Controller for Project Window
 */
Ext.define('PTS.controller.project.window.Window', {
    extend: 'Ext.app.Controller',

    views: [
        'project.window.Window'/*,
        'project.form.ProjectForm'*/
    ],

    refs: [{
        ref: 'projectWindow',
        selector: 'projectwindow'
    }/*,{
        ref: 'projectForm',
        selector: 'projectform'
    }*/],

    init: function() {

        var pf = this.getController('project.form.ProjectForm'),
            pc = this.getController('project.window.ProjectContacts'),
            pa = this.getController('project.window.ProjectAgreements');
        // Remember to call the init method manually
        pf.init();
        pc.init();
        pa.init();

        this.control({
            'projectwindow [action=closewindow]': {
                click: this.closeWindow
            },
            'projectwindow' : {
                beforeclose: this.onBeforeClose
            }/*,

            'projecttab button[action=editproject]': {
                click: this.editProject
            },
            'projectwindow tool[type=save]' : {
                click: this.closeWindow
            }*/
        });
    },

    /**
     * Closes the project window.
     */
    closeWindow: function() {
        this.getProjectWindow().close();
    },

    /**
     * The project window close event.
     */
    onBeforeClose: function() {
        this.application.fireEvent('closeproject');
    }


});
