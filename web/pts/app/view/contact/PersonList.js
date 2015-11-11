/**
 * File: app/view/contact/PersonList.js
 * Description: List of persons.
 */

Ext.define('PTS.view.contact.PersonList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.personlist',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid',
        'Ext.ux.grid.FilterBar',
        'Ext.ux.grid.GrabField'
    ],

    title: 'Person',
    remoteSort: 'true',

    /**
     * Specifies whether to add the FilterBar plugin
     */
    filterBar: true,

    initComponent: function() {
        var me = this,
            docked;

        Ext.applyIf(me, {
            store: 'Persons',
            itemId: 'person', //required for opencontact event
            //dockedItems: [],
            columns: [{
                xtype: 'gridcolumn',
                dataIndex: 'firstname',
                text: 'First'
            }, {
                xtype: 'gridcolumn',
                dataIndex: 'lastname',
                text: 'Last'
            }, {
                xtype: 'gridcolumn',
                dataIndex: 'prigroupname',
                text: 'Primary Group',
                flex: 1
            }, {
                xtype: 'gridcolumn',
                dataIndex: 'priemail',
                text: 'E-mail',
                flex: 1
            }, {
                text: 'Phone',
                defaults: {
                    menuDisabled: true
                },
                columns: [{
                    xtype: 'gridcolumn',
                    dataIndex: 'pricountryiso',
                    text: 'Country',
                    sortable: true,
                    hidden: true,
                    width: 65
                }, {
                    xtype: 'gridcolumn',
                    dataIndex: 'priareacode',
                    text: 'Area',
                    sortable: true,
                    width: 60
                }, {
                    xtype: 'gridcolumn',
                    dataIndex: 'priphnumber',
                    text: 'Phone',
                    width: 100
                }, {
                    xtype: 'gridcolumn',
                    dataIndex: 'priextension',
                    text: 'Ext',
                    width: 75
                }]
            }]
        });

        me.callParent(arguments);

        docked = [{
            xtype: 'pagingtoolbar',
            store: me.store,
            displayInfo: true,
            plugins: [
                Ext.create('Ext.ux.grid.GrabField', {
                    iconCls: 'pts-menu-email',
                    dataindex: 'priemail',
                    tooltip: 'Get all visible e-mail addresses',
                    delimiter: ', \n',
                    windowTitle: 'E-mail addresses'
                }),
                Ext.create('Ext.ux.grid.PrintGrid', {}),
                Ext.create('Ext.ux.grid.SaveGrid', {})
            ],
            dock: 'top'
        }];

        if (me.filterBar) {
            docked.push({
                xtype: 'filterbar',
                searchStore: me.store,
                dock: 'bottom'
            });
        }

        me.addDocked(docked);
    }
});
