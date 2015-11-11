/**
 * Project agreement ItemDetail controller.
 * TODO: When leaving a phantom record prompt to save, if "no" remove from tree
 */
Ext.define('PTS.controller.project.window.ItemDetail', {
    extend: 'Ext.app.Controller',

    views: [
        'project.window.ItemDetail',
        'project.form.ProposalForm'
    ],
    models: [
        'GroupUser',
        'ModType'
    ],
    stores: [
        'GroupUsers',
        'ModTypes'
    ],
    /*refs: [{
        ref: 'projectContacts',
        selector: 'projectcontacts'
    }],*/

    init: function() {
        //TODO: make this an array and ititerate to init controllers
        var ctlrs = [
            this.getController('project.form.AgreementForm'),
            this.getController('project.form.ModificationForm'),
            this.getController('project.form.ProposalForm'),
            this.getController('project.form.FundingForm'),
            this.getController('project.form.DeliverableForm'),
            this.getController('project.form.TaskForm')
        ];
        // Remember to call the init method manually
        Ext.each(ctlrs, function(c) {
            c.init();
        });

        /*this.control({
            'agreementstree': {
                beforerender: this.beforeRender
            },
            'agreementstree tool[type=expand]': {
                click: this.expandAll
            }
        });*/

        // We listen for the application-wide openproject event
        /*this.application.on({
            openproject: this.onOpenProject,
            scope: this
        });*/
    }

    /*
     * Stuff to do when Project Contacts tab is activated.
     */
    /*activate: function(tab) {

    },*/

    /*
     * Contact list tab activated.
     */
    /*activateList: function(grid) {
       var store = grid.getStore();

       //load the contact list
       if (store.getCount() == 0) {
           store.load();
       }
    },*/

});
