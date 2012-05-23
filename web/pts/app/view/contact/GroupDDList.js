/**
 * File: app/view/contact/GroupDDList.js
 * Description: List of contact groups with dragdrop and checkbox selection.
 */
Ext.define('PTS.view.contact.GroupDDList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.groupddlist',
    requires: [
        //'PTS.util.Format'
    ],

    title:'Groups',
    store: 'ContactGroups',
    itemId: 'groupsList', //do not change

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            selModel: Ext.create('Ext.selection.CheckboxModel', {
                injectCheckbox: false,
                mode: 'SIMPLE'
            }),
            viewConfig: {
                copy: true,
                plugins: {
                    ptype: 'gridviewdragdrop'
                }
            },
            dockedItems: [{
                xtype: 'pagingtoolbar',
                store: 'ContactGroups',
                displayInfo: false
            }],
            columns: [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'name',
                    flex: 1,
                    text: 'Name'
                }
            ]
        });

        me.callParent(arguments);
    }
});
