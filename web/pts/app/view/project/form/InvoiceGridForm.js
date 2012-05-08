/**
 * File: app/view/project/form/InvoiceGridForm.js
 * Card panel with grid and form for viewing and editing invoices.
 */

Ext.define('PTS.view.project.form.InvoiceGridForm', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.invoicegridform',
    requires: [
        'PTS.view.controls.RowEditGrid',
        'PTS.view.controls.CurrencyField',
        'Ext.util.Format.usMoney'
    ],

    activeItem: 0,
    layout: {
        type: 'card'
    },
    title: 'Invoices',
    defaults: {
        autoScroll: true,
        border: 0
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'gridpanel',
                    itemId: 'invoiceList',
                    uri: 'invoice',
                    store: 'Invoices',
                    columns: [
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'title',
                            text: 'Title',
                            flex: 1
                        },
                        {
                            xtype: 'numbercolumn',
                            dataIndex: 'amount',
                            text: 'Amount'
                        },
                        /*{
                            xtype: 'gridcolumn',
                            dataIndex: 'string',
                            text: 'Contact',
                            flex: 1,
                            hidden: true
                        },*/
                        {
                            xtype: 'datecolumn',
                            dataIndex: 'datereceived',
                            text: 'Received'
                        },
                        {
                            xtype: 'datecolumn',
                            dataIndex: 'dateclosed',
                            text: 'Closed'
                        }
                    ],
                    dockedItems: [
                        {
                            xtype: 'toolbar',
                            dock: 'top',
                            items: [
                                {
                                    xtype: 'button',
                                    text: 'Edit',
                                    iconCls: 'pts-menu-editbasic',
                                    action: 'editinvoice',
                                    disabled: true
                                },
                                {
                                    xtype: 'button',
                                    text: 'Add',
                                    iconCls: 'pts-menu-addbasic',
                                    action: 'addinvoice'
                                }/*,
                                {
                                    xtype: 'button',
                                    text: 'Remove'
                                }*/
                            ]
                        }
                    ]
                },
                {
                    xtype: 'form',
                    itemId: 'invoiceForm',
                    model: 'PTS.model.Invoice',
                    trackResetOnLoad: true,
                    border: 0,
                    layout: {
                        align: 'stretch',
                        padding: 10,
                        type: 'vbox'
                    },
                    dockedItems: [
                        {
                            xtype: 'toolbar',
                            dock: 'top',
                            items: [
                                {
                                    xtype: 'button',
                                    action: 'showlist',
                                    iconCls: 'pts-menu-viewlist',
                                    text: 'Show List'
                                },
                                {
                                    xtype: 'button',
                                    action: 'deleteinvoice',
                                    iconCls: 'pts-menu-deletebasic',
                                    text: 'Delete'
                                    //disabled: true,

                                },{
                                    xtype: 'button',
                                    action: 'saveinvoice',
                                    iconCls: 'pts-menu-savebasic',
                                    text: 'Save',
                                    formBind: true
                                },
                                {
                                    xtype: 'button',
                                    action: 'resetinvoice',
                                    iconCls: 'pts-menu-reset',
                                    text: 'Reset'
                                    //disabled: true,
                                }
                            ]
                        }
                    ],
                    items: [
                        {
                            xtype: 'container',
                            border: 0,
                            padding: '0 0 10 0',
                            layout: {
                                type: 'anchor'
                            },
                            items: [
                                {
                                    xtype: 'textfield',
                                    name: 'title',
                                    fieldLabel: 'Title',
                                    anchor: '100%',
                                    allowBlank: false
                                },
                                {
                                    xtype: 'combobox',
                                    name: 'projectcontactid',
                                    fieldLabel: 'Contact',
                                    displayField: 'name',
                                    valueField: 'projectcontactid',
                                    store: 'ProjectInvoicers',
                                    typeAhead: false,
                                    queryMode: 'local',
                                    forceSelection: true,
                                    allowBlank: false,
                                    anchor: '100%'
                                },
                                {
                                    xtype: 'currencyfield',
                                    name: 'amount',
                                    fieldLabel: 'Amount'
                                },
                                {
                                    xtype: 'fieldcontainer',
                                    layout: {
                                        type: 'hbox'
                                    },
                                    fieldLabel: 'Dates',
                                    hideLabel: true,
                                    items: [
                                        {
                                            xtype: 'datefield',
                                            name: 'datereceived',
                                            fieldLabel: 'Received',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'datefield',
                                            name: 'dateclosed',
                                            margin: '0 0 0 10',
                                            fieldLabel: 'Closed',
                                            labelAlign: 'right',
                                            labelPad: 15,
                                            flex: 0
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            xtype: 'roweditgrid',
                            itemId: 'costCodes',
                            title: 'Cost Codes',
                            //store: 'CostCodeInvoices',
                            flex: 1,
                            columns: [
                                {
                                    xtype: 'gridcolumn',
                                    dataIndex: 'costcodeid',
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
                                        displayField: 'costcode',
                                        valueField: 'costcodeid',
                                        store: 'CostCodes',
                                        typeAhead: false,
                                        queryMode: 'local',
                                        forceSelection: true,
                                        allowBlank: false
                                    },
                                    text: 'Cost Code',
                                    flex: 2
                                },
                                {
                                    xtype: 'datecolumn',
                                    dataIndex: 'datecharged',
                                    editor: {
                                        xtype: 'datefield'
                                    },
                                    text: 'Date Charged'
                                },
                                {
                                    xtype: 'numbercolumn',
                                    dataIndex: 'amount',
                                    editor: {
                                        xtype: 'currencyfield',
                                        allowBlank: false
                                    },
                                    flex: 1,
                                    text: 'Amount',
                                    renderer: Ext.util.Format.usMoney
                                }
                            ]
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }

});
