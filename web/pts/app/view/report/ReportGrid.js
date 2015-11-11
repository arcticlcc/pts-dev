/**
 * Used to generate Report grid panels.
 */

Ext.define('PTS.view.report.ReportGrid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.reportgrid',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid',
        'Ext.ux.grid.GrabField',
        'Ext.ux.grid.PagingToolbarResizer',
        'Ext.ux.grid.FilterBar'

    ],

    autoScroll: true,
    title: 'Report',
    store: undefined,


    pbarPlugins: [],

    initComponent: function() {
        var me = this;

        /*Ext.applyIf(me, {
        });*/

        me.callParent(arguments);

        me.addDocked({
            xtype: 'pagingtoolbar',
            store: me.store, // same store GridPanel is using
            dock: 'top',
            displayInfo: true,
            plugins: me.pbarPlugins.concat([
                Ext.create('Ext.ux.grid.PrintGrid', {
                    /*title: function(){
                        return this.child('cycle#filter').getActiveItem().text + ' (Tasks)';
                    }*/
                }),
                Ext.create('Ext.ux.grid.SaveGrid', {}),
                Ext.create('Ext.ux.grid.PagingToolbarResizer', {
                    options: [25, 50, 100, 200]
                })
            ])
        });
    }
});
