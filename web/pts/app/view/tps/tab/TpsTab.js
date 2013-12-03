/**
 * @author Joshua Bradley
 * Panel with grid and form showing status of contract
 * paperwork for each project agreement.
 */

Ext.define('PTS.view.tps.tab.TpsTab', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.tpstab',
    requires: [
        'PTS.view.tps.tab.TpsGrid',
        'PTS.view.tps.tab.TpsDetailGrid'
    ],

    layout: {
        type: 'border'
    },
    title: 'TPS Report',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'tpsgrid',
                    itemId: 'tpsGrid',
                    region: 'center'
                },
                {
                    xtype: 'tpsdetailgrid',
                    itemId: 'tpsDetail',
                    title: 'Details',
                    region: 'east',
                    split: true,
                    flex: 0.5,
                    minWidth: 350,
                    collapsible: true
                }
            ]
        });

        me.callParent(arguments);
    }
});