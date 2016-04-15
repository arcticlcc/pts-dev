/**
 * Description: Product Processing Steps panel.
 */

Ext.define('PTS.view.product.window.ProductSteps', {
    extend: 'PTS.view.controls.GridForm',
    alias: 'widget.productsteps',
    requires: [
      'Ext.button.Button',
      'Ext.toolbar.Toolbar',
      'Ext.grid.plugin.DragDrop'
    ],

    title: 'Process Steps',
    detailTitle: 'Step Details',
    store: 'ProductSteps',

    gridViewConfig: {
        plugins: [{
            ptype: 'gridviewdragdrop',
            pluginId: 'stepsddplugin'
        }]
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            columns: [{
                text: '#',
                sortable: false,
                dataIndex: 'priority'
            }, {
                text: 'Description',
                flex: 2,
                sortable: false,
                dataIndex: 'description'
            }, {
                text: 'Date',
                xtype: 'datecolumn',
                flex: 1,
                sortable: false,
                dataIndex: 'stepdate'
            }/*, {
                text: 'Processor',
                flex: 1,
                sortable: true,
                dataIndex: 'contactid',
                renderer: function(value, metaData, record, rowIdx, colIdx, store, view) {
                    var rec = Ext.getStore('ProductContacts').findRecord('contact', value, 0, false, true, true);

                    if (rec) {
                        return rec.get('fullname');
                    }
                    return value;
                }
            }*/],
            fields: [{
                fieldLabel: 'Priority',
                name: 'priority',
                //xtype: 'numberfield',
                disabled: true,
                minValue: 0,
                maxWidth: 150
            }, {
                fieldLabel: 'Description',
                xtype: 'textareafield',
                name: 'description',
                allowBlank: false,
                grow: true,
                growMin: 80,
                anchor: '100%'
            }, {
                fieldLabel: 'Rationale',
                xtype: 'textareafield',
                name: 'rationale',
                allowBlank: false,
                grow: true,
                growMin: 80,
                anchor: '100%'
            }, {
                fieldLabel: 'Date',
                name: 'stepdate',
                xtype: 'datefield',
                maxWidth: 250
            }, {
                fieldLabel: 'Processor',
                name: 'productcontactid',
                xtype: 'combobox',
                displayField: 'namerole',
                /*listConfig: {
                    getInnerTpl: function() {
                        return '<div>{name} ({role})</div>';
                    }
                },*/
                store: 'ProductContacts',
                valueField: 'productcontactid',
                forceSelection: true,
                allowBlank: false,
                queryMode: 'local',
                anchor: '50%'
            }]
        });

        me.callParent(arguments);
    }
});
