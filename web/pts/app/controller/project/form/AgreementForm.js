/**
 * Controller for Agreement Form
 */
Ext.define('PTS.controller.project.form.AgreementForm', {
    extend: 'PTS.controller.project.form.BaseModificationForm',

    views: [
        'project.form.AgreementForm'
    ],
    models: [
        'PurchaseRequest',
        'Status',
        'ModStatus'
    ],
    stores: [
        'PurchaseRequests',
        'Statuses',
        'ModStatuses',
        'ModificationComments'
    ],
    refs: [{
        ref: 'agreementForm',
        selector: 'agreementform#itemCard-20 #itemForm'
    },{
        ref: 'agreementCard',
        selector: 'agreementform#itemCard-20'
    }],

    init: function() {
        this.control({
            'agreementform#itemCard-20 roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
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
