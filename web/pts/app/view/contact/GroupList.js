/**
 * File: app/view/contact/GroupList.js
 * Description: List of contact groups.
 */

Ext.define('PTS.view.contact.GroupList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.grouplist',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid'
    ],

    title:'Group',
    store: 'ContactGroups',
    itemId: 'group', //do not change

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            dockedItems: [{
                xtype: 'pagingtoolbar',
                store: 'ContactGroups',
                displayInfo: true,
                plugins: [
                    Ext.create('Ext.ux.grid.PrintGrid', {}),
                    Ext.create('Ext.ux.grid.SaveGrid', {})
                ]
            }],
            columns: [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'fullname',
                    text: 'Full Name',
                    flex:1
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'name',
                    text: 'Name',
                    flex:1,
                    hidden: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'acronym',
                    text: 'Acronym'
                },
                {
                    xtype: 'booleancolumn',
                    dataIndex: 'organization',
                    text: 'Organization?',
                    trueText: 'Yes',
                    falseText: 'No'
                }

            ]
        });

        me.callParent(arguments);
    }
});
