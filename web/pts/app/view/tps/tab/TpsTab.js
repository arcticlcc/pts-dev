/**
 * @author Joshua Bradley
 * Panel with grid and form showing status of contract
 * paperwork for each project agreement.
 */

Ext.define('PTS.view.tps.tab.TpsTab', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.tpstab',
    requires: [
        'PTS.view.tps.tab.TpsGrid'
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
                    xtype: 'panel',
                    itemId: 'tpsDetail',
                    title: 'Details',
                    region: 'south',
                    split: true,
                    height: 250
                }
            ]
        });

        me.callParent(arguments);
    }
});