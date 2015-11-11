/**
 * File: app/view/project/window/ItemDetail.js
 * Description: Project Items card panel.
 */

Ext.define('PTS.view.project.window.ItemDetail', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.agreementitemdetail',
    requires: [
        'PTS.view.project.form.ProposalForm',
        'PTS.view.project.form.AgreementForm',
        'PTS.view.project.form.DeliverableForm',
        'PTS.view.project.form.TaskForm',
        'PTS.view.project.form.FundingForm',
        'PTS.view.project.form.ModificationForm'
    ],

    itemId: 'itemDetail',
    style: {
        borderWidth: '1px 0 0 1px',
        padding: 0
    },
    activeItem: 0,
    layout: {
        type: 'card'
    },
    title: 'Detail',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            defaults: {
                preventHeader: true,
                trackResetOnLoad: true,
                autoScroll: false,
                border: 0
            },
            items: [{
                xtype: 'container',
                html: '<div style="margin: 2em auto;text-align:center;">' +
                    'Use the toolbar to create a new item or select an' +
                    'existing item from the tree.</div>',
                itemId: 'itemCard-0'
            }, {
                xtype: 'proposalform',
                itemId: 'itemCard-10',
                title: 'Proposal'
            }, {
                xtype: 'agreementform',
                itemId: 'itemCard-20',
                title: 'Agreement'
            }, {
                xtype: 'deliverableform',
                itemId: 'itemCard-30',
                title: 'Deliverable'
            }, {
                xtype: 'taskform',
                itemId: 'itemCard-40',
                title: 'Task'
            }, {
                xtype: 'fundingform',
                title: 'Funding',
                itemId: 'itemCard-50'
            }, {
                xtype: 'modificationform',
                title: 'Modification',
                itemId: 'itemCard-60'
            }],
            dockedItems: [{
                xtype: 'toolbar',
                itemId: 'mainItemToolbar',
                dock: 'top'
            }]
        });

        me.callParent(arguments);
    }
});
