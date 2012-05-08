/**
 * File: app/view/project/form/FundingForm.js
 * Form for editing Funding information.
 */

Ext.define('PTS.view.project.form.FundingForm', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.fundingform',
    requires: ['PTS.view.controls.CurrencyField'],

    itemId: 'itemCard-50',
    title: 'Funding',
    layout: 'border',
    defaults: {
        trackResetOnLoad: true,
        autoScroll: false,
        preventHeader: true
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'form',
                itemId: 'itemForm',
                model: 'PTS.model.Funding',
                title: 'Funding',
                layout:'anchor',
                region: 'north',
                height: 200,
                collapsible: true,
                animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                split: true,
                bodyPadding: 10,
                autoScroll: true,
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
                        fieldLabel: 'Funding Source',
                        anchor: '100%',
                        store: 'ProjectFunders',
                        displayField: 'name',
                        valueField: 'projectcontactid',
                        forceSelection: true,
                        allowBlank: false,
                        queryMode: 'local'
                    },
                    {
                        xtype: 'combobox',
                        name: 'fundingtypeid',
                        fieldLabel: 'Type',
                        anchor: '100%',
                        store: 'FundingTypes',
                        displayField: 'type',
                        valueField: 'fundingtypeid',
                        forceSelection: true,
                        allowBlank: false,
                        queryMode: 'local',
                        listConfig: {
                            getInnerTpl: function() {
                                return '<div data-qtip="{description}">{type}</div>';
                            }
                        }
                    },
                    {
                        xtype: 'currencyfield',
                        name: 'amount',
                        fieldLabel: 'Amount',
                        allowBlank: false,
                        minValue: 0.01
                    }
                ]
            },{
                xtype:'tabpanel',
                itemId: 'relatedDetails',
                title: 'Details',
                region: 'center',
                //height: 400,
                //collapsible: true,
                //split: true,
                activeTab: 0,
                //flex: 1,
                //defaults:{bodyStyle:'padding:10px'},
                items:[{
                    xtype: 'roweditgrid',
                    store: 'CostCodes',
                    uri: 'costcode',
                    title:'Cost Codes',
                    columns: [
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'costcode',
                            width: 250,
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
                                store: 'ContactCostCodes',
                                queryMode: 'local',
                                displayField: 'costcode',
                                valueField: 'costcode',
                                typeAhead: false,
                                allowBlank: false,
                                blankText: 'A Cost Code is required.'
                            },
                            text: 'Cost Code'
                        },
                        {
                            xtype: 'datecolumn',
                            dataIndex: 'startdate',
                            editor: {
                                xtype: 'datefield',
                                allowBlank: false,
                                blankText: 'The Start Date is required.'
                            },
                            text: 'Start Date'
                        },
                        {
                            xtype: 'datecolumn',
                            dataIndex: 'enddate',
                            editor: {
                                xtype: 'datefield',
                                allowBlank: false,
                                blankText: 'The End Date is required.'
                            },
                            text: 'End Date'
                        }
                    ]
                },{
                    xtype: 'invoicegridform',
                    title:'Invoices'
                },{
                    title: 'Comments',
                    disabled: true
                }]
            }]
        });

        me.callParent(arguments);
    }
});
