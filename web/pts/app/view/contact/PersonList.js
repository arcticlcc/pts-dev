/**
 * File: app/view/contact/PersonList.js
 * Description: List of persons.
 */

Ext.define('PTS.view.contact.PersonList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.personlist',
    requires: [
        //'PTS.util.Format'
    ],

    title:'Person',
    store: 'Persons',
    itemId: 'person', //do not change, required for opencontact event
    remoteSort: 'true',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            dockedItems: [{
                xtype: 'pagingtoolbar',
                store: 'Persons',
                displayInfo: true
            }],
            columns: [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'firstname',
                    text: 'First'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'lastname',
                    text: 'Last'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'prigroupname',
                    text: 'Primary Group',
                    flex:1
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'priemail',
                    text: 'E-mail',
                    flex:1
                },
                {
                    text: 'Phone',
                    defaults: {
                        menuDisabled: true
                    },
                    columns: [
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'pricountryiso',
                            text: 'Country',
                            sortable: true,
                            hidden: true,
                            width: 65
                        },
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'priareacode',
                            text: 'Area',
                            sortable: true,
                            width: 60
                        },
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'priphnumber',
                            text: 'Phone',
                            width: 100
                        },
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'priextension',
                            text: 'Ext',
                            width: 75
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
