/**
 * Used to generate Report grid panels.
 */

Ext.define('PTS.view.report.ReportGrid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.reportgrid',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid'
    ],

    autoScroll: true,
    title: 'Report',
    store: undefined,

    initComponent: function() {
        var me = this;

        /*Ext.applyIf(me, {
        });*/

        me.callParent(arguments);

        me.addDocked(
            {
                xtype: 'pagingtoolbar',
                store: me.store,   // same store GridPanel is using
                dock: 'top',
                displayInfo: true,
                plugins: [
                    Ext.create('Ext.ux.grid.PrintGrid', {
                        /*title: function(){
                            return this.child('cycle#filter').getActiveItem().text + ' (Tasks)';
                        }*/
                    }),
                    Ext.create('Ext.ux.grid.SaveGrid', {})
                ]
            }
        );
    }
});
