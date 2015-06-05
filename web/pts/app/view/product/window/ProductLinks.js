/**
 * Description: Product Links panel.
 */

Ext.define('PTS.view.product.window.ProductLinks', {
    extend: 'PTS.view.controls.GridForm',
    alias: 'widget.productlinks',
    requires: ['Ext.button.Button', 'Ext.toolbar.Toolbar'],

    title: 'Links',
    store: 'OnlineResources',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            columns: [{
                text: 'Title',
                flex: 2,
                sortable: true,
                dataIndex: 'title'
            }, {
                text: 'Link (URL)',
                flex: 3,
                sortable: true,
                dataIndex: 'uri'
            }, {
                text: 'Function',
                flex: 1,
                sortable: true,
                dataIndex: 'onlinefunctionid',
                renderer: function(value, metaData, record, rowIdx, colIdx, store, view) {
                    var rec = Ext.getStore('OnlineFunctions').findRecord('onlinefunctionid', value, 0, false, true, true);

                    if (rec) {
                        return rec.get('codename');
                    }
                    return value;
                }
            }],
            fields: [{
                fieldLabel: 'Title',
                name: 'title'
            }, {
                fieldLabel: 'Link (URL)',
                name: 'uri',
                vtype: 'url',
                emptyText: 'http://'
            }, {
                fieldLabel: 'Function',
                name: 'onlinefunctionid',
                xtype: 'combobox',
                displayField: 'codename',
                listConfig: {
                    getInnerTpl: function() {
                        return '<div>{codename}: {description}</div>';
                    }
                },
                store: 'OnlineFunctions',
                valueField: 'onlinefunctionid',
                forceSelection: true,
                allowBlank: false,
                queryMode: 'local',
                anchor: '100%'
            }, {
                fieldLabel: 'Description',
                xtype: 'textareafield',
                name: 'description',
                allowBlank: false,
                grow: true,
                growMin: 80,
                anchor: '100%'
            }]
        });

        me.callParent(arguments);
    }
});
