/**
 * Grid for TPS document details.
 */

Ext.define('PTS.view.tps.tab.TpsDetailGrid', {
    extend: 'PTS.view.controls.RowEditGrid',
    alias: 'widget.tpsdetailgrid',
    requires: [
        'PTS.store.GroupUsers',
        'PTS.store.ModDocStatusTypes',
        'PTS.view.controls.TextareaTriggerField'
    ],

    autoScroll: true,
    store: 'ModDocStatuses',

    initComponent: function() {
        var me = this,
            cols = [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'moddocstatustypeid',
                    text: 'Status',
                    renderer: function(value) {
                        var store = Ext.getStore('ModDocStatusTypes'),
                            idx = store.find('moddocstatustypeid', value, 0, false, true, true),
                            rec = store.getAt(idx);
                        if (rec) {
                            return rec.get('code');
                        }
                        return value;
                    },
                    editor: {
                        xtype: 'statuscombo',
                        store: 'ModDocStatusTypes',
                        valueField: 'moddocstatustypeid',
                        allowBlank: false
                    }
                },
                {
                    xtype: 'datecolumn',
                    dataIndex: 'effectivedate',
                    text: 'Date',
                    editor: {
                        xtype: 'datefield',
                        allowBlank: false
                    }
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'comment',
                    text: 'Comment',
                    flex: 1,
                    editor: {
                        xtype: 'areatrigger',
                        text: 'Comment',
                        allowBlank: false
                    }
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'contactid',
                    width: 125,
                    renderer: function(value) {
                        var store = Ext.getStore('GroupUsers'),
                            idx = store.find('contactid', value, 0, false, true, true),
                            rec = store.getAt(idx);
                        if (rec) {
                            return rec.get('fullname');
                        }
                        return value;
                    },
                    text: 'User'
                }

            ];

        Ext.applyIf(me, {
            viewConfig: {

            },
            columns: cols
        });

        me.callParent(arguments);
        me.getStore().on('add', function(store, records){
            Ext.each(records, function() {
                var rec = this;

                if(null === rec.get('contactid')) {
                    rec.set('contactid', PTS.user.get('contactid'));
                }
            });
        });
    }
});
