/**
 * File: app/view/contact/GroupDDList.js
 * Description: List of contact groups with dragdrop and checkbox selection.
 */
Ext.define('PTS.view.contact.GroupDDList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.groupddlist',
    requires: [
        'Ext.ux.grid.FilterBar',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.DragDrop'
    ],

    title:'Groups',
    store: 'DDContactGroups',
    itemId: 'groupsList', //do not change

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            selModel: Ext.create('Ext.selection.CheckboxModel', {
                injectCheckbox: false,
                mode: 'SIMPLE',
                checkOnly: true
            }),
            viewConfig: {
                copy: true,
                plugins: {
                    ptype: 'gridviewdragdrop'
                }
            },
            dockedItems: [{
                xtype: 'pagingtoolbar',
                store: 'DDContactGroups',
                displayInfo: false
            }],
            columns: [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'fullname',
                    flex: 1,
                    text: 'Full Name'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'acronym',
                    text: 'Acronym'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'name',
                    flex: 1,
                    text: 'Name',
                    hidden: true
                }
            ]
        });

        me.callParent(arguments);

        me.addDocked({
                xtype: 'filterbar',
                searchStore: me.store,
                dock: 'bottom'
        });
    }
});
