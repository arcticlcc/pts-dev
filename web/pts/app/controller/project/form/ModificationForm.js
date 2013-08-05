/**
 * Controller for Modification Form
 */
Ext.define('PTS.controller.project.form.ModificationForm', {
    extend: 'PTS.controller.project.form.BaseModificationForm',

    views: [
        'project.form.AgreementForm',
        'project.form.ModificationForm'
    ],
    models: [
        'PurchaseRequest',
        'Status',
        'ModStatus'
    ],
    stores: [
        'PurchaseRequests',
        'Statuses',
        'ModStatuses'
    ],
    refs: [{
        ref: 'agreementForm',
        selector: 'modificationform#itemCard-60 #itemForm'
    },{
        ref: 'agreementCard',
        selector: 'modificationform#itemCard-60'
    }],

    init: function() {
        this.control({
            'modificationform#itemCard-60 roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            },
            'agreementform#itemCard-60 #statusGrid': {
                validateedit: this.validateStatus
            }
        });

        // We listen for the application-wide loaditem event
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });

    }
});
