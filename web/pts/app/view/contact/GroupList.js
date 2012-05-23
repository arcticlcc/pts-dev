/**
 * File: app/view/contact/GroupList.js
 * Description: List of contact groups.
 */

Ext.define('PTS.view.contact.GroupList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.grouplist',
    requires: [
        //'PTS.util.Format'
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
                displayInfo: true
            }],
            columns: [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'name',
                    text: 'Name',
                    flex:1
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
