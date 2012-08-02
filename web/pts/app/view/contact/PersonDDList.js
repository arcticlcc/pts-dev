/**
 * File: app/view/contact/PersonDDList.js
 * Description: List of contact persons with dragdrop and checkbox selection.
 */
Ext.define('PTS.view.contact.PersonDDList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.personddlist',
    requires: [
        //'PTS.util.Format'
    ],

    title:'Persons',
    store: 'Persons',
    itemId: 'personsList', //do not change

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
                store: 'Persons',
                displayInfo: false
            }],
            columns: [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'firstname',
                    flex: 1,
                    text: 'First Name'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'lastname',
                    flex: 3,
                    text: 'Last Name'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'priacronym',
                    width: 60,
                    text: 'Group'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'prigroupname',
                    flex: 2,
                    hidden: true,
                    text: 'Group Name'
                }
            ]
        });

        me.callParent(arguments);
    }
});
