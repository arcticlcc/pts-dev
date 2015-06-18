/**
 * File: app/view/product/window/ProductContacts.js
 * Description: Product Contacts tab panel.
 */

Ext.define('PTS.view.product.window.ProductContacts', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.productcontacts',
    requires: [
        'Ext.ux.CheckColumn',
        'Ext.ux.grid.HeaderToolTip',
        'PTS.view.contact.ContactLists',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.DragDrop'
    ],

    layout: {
        align: 'stretch',
        padding: 5,
        type: 'hbox'
    },
    title: 'Contacts',

    initComponent: function() {
        var me = this,
            editor;

        editor = Ext.create('Ext.grid.plugin.CellEditing', {
            itemId: 'contactEditor',
            pluginId: 'contactEditor',
            clicksToEdit: 1,
            listeners: {//TODO: move to controller??
                beforeedit : function(event) { //needed to prevent editing of selection checkbox
                    if (event.column && (event.column.isCheckerHd || event.column.is('actioncolumn'))) {
                        return false;
                    }

                    return true;
                }
            }
        });

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'contactlists',
                    addBtnText: 'Add to Product',
                    flex: 1
                },
                {
                    xtype: 'gridpanel',
                    itemId: 'productContactsList',
                    title: 'Product Contacts',
                    store: 'ProductContacts',
                    flex: 1,
                    selModel: Ext.create('Ext.selection.CheckboxModel', {
                        injectCheckbox: false,
                        mode: 'SIMPLE',
                        checkOnly: true
                    }),
                    plugins: [
                        editor,
                        'headertooltip'
                    ],
                    viewConfig: {
                        plugins: [{
                            ptype: 'gridviewdragdrop',
                            pluginId: 'contactsddplugin'
                        }]
                    },
                    dockedItems: [
                        {
                            xtype: 'toolbar',
                            dock: 'top',
                            items: [
                                {
                                    xtype: 'button',
                                    iconCls: 'pts-menu-deletebasic',
                                    text: 'Remove',
                                    action: 'removecontacts'
                                },
                                {
                                    xtype: 'button',
                                    iconCls: 'pts-menu-savebasic',
                                    text: 'Save',
                                    action: 'savecontacts'
                                },
                                {
                                    xtype: 'button',
                                    iconCls: 'pts-menu-refresh',
                                    text: 'Refresh',
                                    action: 'refreshcontacts'
                                }
                            ]
                        },
                        {
                            xtype: 'pagingtoolbar',
                            store: 'ProductContacts',
                            displayInfo: true
                        }
                    ],
                    columns: [
                        {
                            xtype: 'gridcolumn',
                            sortable: false,
                            dataIndex: 'name',
                            flex: 1,
                            text: 'Name'
                        },
                        {
                            xtype: 'gridcolumn', //TODO: add xtype with generic renderer
                            dataIndex: 'isoroletypeid',
                            renderer: function(value, metaData, record, rowIdx, colIdx , store, view) {
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
                                itemId: 'roletypeCbx',
                                typeAhead: true,
                                forceSelection: true,
                                triggerAction: 'all',
                                displayField: 'codename',
                                valueField: 'isoroletypeid',
                                selectOnTab: true,
                                store: 'IsoRoleTypes',
                                lazyRender: true,
                                listClass: 'x-combo-list-small',
                                queryMode: 'local',
                                listConfig: {
                                    getInnerTpl: function() {
                                        return '<div data-qtip="{description}">{codename}</div>';
                                    }
                                },
                                listeners: {
                                    blur: function(c) {
                                        c.getStore().clearFilter();
                                    }
                                }
                            },
                            flex: 1,
                            text: 'Role'
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
