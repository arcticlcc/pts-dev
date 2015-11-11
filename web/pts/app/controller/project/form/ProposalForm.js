/**
 * Controller for Proposal Form
 */
Ext.define('PTS.controller.project.form.ProposalForm', {
    extend: 'PTS.controller.project.form.BaseModificationForm',

    views: [
        'project.form.ProposalForm'
    ],
    models: [
        'Status',
        'ModStatus'
    ],
    stores: [
        'Statuses',
        'ModStatuses',
        'ModificationComments'
    ],
    refs: [{
        ref: 'agreementForm',
        selector: 'proposalform#itemCard-10 #itemForm'
    }, {
        ref: 'agreementCard',
        selector: 'proposalform#itemCard-10'
    }],

    init: function() {
        this.control({
            'proposalform#itemCard-10 roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            }
        });

        // We listen for the application-wide itemload event
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });
    }
});
