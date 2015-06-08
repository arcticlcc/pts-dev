/**
 * Description: Product Status panel.
 */

Ext.define('PTS.view.product.window.ProductStatus', {
    extend: 'PTS.view.controls.RowEditGrid',
    alias: 'widget.productstatus',
    requires: ['Ext.form.field.ComboBox', 'PTS.store.GroupUsers'],

    title: 'Status',
    store: 'ProductStatuses',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            columns: [{
                xtype: 'gridcolumn',
                dataIndex: 'datetypeid',
                renderer: function(value, metaData, record, rowIdx, colIdx, store, view) {
                    var combo = view.getHeaderAtIndex(colIdx).getEditor(),
                        idx = combo.getStore().find(combo.valueField, value, 0, false, true, true),
                        rec = combo.getStore().getAt(idx);
                    if (rec) {
                        return rec.get(combo.displayField);
                    }
                    return value;
                },
                editor: {
                    xtype: 'combobox',
                    displayField: 'codename',
                    listConfig: {
                        getInnerTpl: function() {
                            return '<div data-qtip="{description}">{codename}</div>';
                        }
                    },
                    store: 'DateTypes',
                    valueField: 'datetypeid',
                    forceSelection: true,
                    allowBlank: false,
                    queryMode: 'local'
                },
                text: 'Status'
            }, {
                xtype: 'datecolumn',
                dataIndex: 'effectivedate',
                editor: {
                    xtype: 'datefield',
                    allowBlank: false
                },
                text: 'Effective Date'
            }, {
                xtype: 'gridcolumn',
                dataIndex: 'contactid',
                hidden: true,
                renderer: function(value) {
                    var store = Ext.getStore('GroupUsers'), idx = store.find('contactid', value, 0, false, true, true), rec = store.getAt(idx);
                    if (rec) {
                        return rec.get('fullname');
                    }
                    return value;
                },
                text:'User'
            }, {
                xtype: 'gridcolumn',
                dataIndex: 'comment',
                editor: {
                    xtype: 'textfield'
                },
                flex: 2,
                text: 'Comment'
            }]
        });

        me.callParent(arguments);
    }
});
