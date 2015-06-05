/**
 * File: app/view/product/form/ProductForm.js
 * Form for editing basic product information.
 */

Ext.define('PTS.view.product.form.ProductForm', {
    extend: 'Ext.form.Panel',
    alias: 'widget.productform',
    requires: [
        'PTS.view.controls.DateRangeField',
        'Ext.form.field.Display'
    ],

    autoScroll: true,
    bodyPadding: 5,
    title: 'Product',

    initComponent: function() {
        var me = this;

        me.initialConfig = Ext.apply({
            trackResetOnLoad: true
        }, me.initialConfig);

        Ext.applyIf(me, {
            dockedItems: [
                {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        /*{
                            xtype: 'button',
                            text: 'Edit',
                            iconCls: 'pts-menu-editbasic',
                            hidden: true,
                            action: 'editproduct'
                        },*/
                        {
                            xtype: 'button',
                            text: 'Delete',
                            iconCls: 'pts-menu-deletebasic',
                            //disabled: true,
                            action: 'deleteproduct'
                        },
                        {
                            xtype: 'button',
                            text: 'Save',
                            iconCls: 'pts-menu-savebasic',
                            formBind: true,
                            action: 'saveproduct',
                            formBind: true
                        },
                        {
                            xtype: 'button',
                            text: 'Reset',
                            iconCls: 'pts-menu-reset',
                            //disabled: true,
                            action: 'resetproduct'
                        }
                    ]
                }
            ],
            items: [
                {
                    xtype: 'fieldset',
                    title: 'Product',
                    anchor: '-15',
                    items: [
                        {
                            xtype: 'textfield',
                            name: 'title',
                            fieldLabel: 'Title',
                            allowBlank: false,
                            emptyText: 'Product Title',
                            maxLength: 150,
                            enforceMaxLength: true,
                            anchor: '100%'
                        },
                        /*{
                            xtype: 'textfield',
                            name: 'shorttitle',
                            fieldLabel: 'Short Title',
                            allowBlank: false,
                            emptyText: 'Short Title',
                            maxLength: 60,
                            enforceMaxLength: true,
                            anchor: '60%'
                        },*/
                        {
                            xtype: 'combobox',
                            name: 'projectid',
                            forceSelection: true,
                            allowBlank: false,
                            queryMode: 'local',
                            fieldLabel: 'Project',
                            displayField: 'projectcode',
                            listConfig: {
                                getInnerTpl: function() {
                                    return '<div>{projectcode}: {shorttitle}</div>';
                                }
                            },
                            store: 'ProjectIDs',
                            valueField: 'projectid',
                            anchor: '100%'
                        },
                        {
                            xtype: 'fieldcontainer',
                            layout: {
                                type: 'anchor'
                            },
                            fieldLabel: 'Dates',
                            items: [
                                {
                                    xtype: 'daterangefield',
                                    itemId: 'startDate',
                                    name: 'startdate',
                                    fieldLabel: 'Start',
                                    allowBlank: true,
                                    vfield: 'beginDate',
                                    endDateField: 'endDate',
                                    vtype: 'daterange',
                                    labelWidth: 50
                                },
                                {
                                    xtype: 'daterangefield',
                                    itemId: 'endDate',
                                    name: 'enddate',
                                    allowBlank: true,
                                    vfield: 'endDate',
                                    startDateField: 'startDate',
                                    vtype: 'daterange',
                                    fieldLabel: 'End',
                                    labelWidth: 50
                                }
                            ]
                        },
                        {
                            xtype: 'displayfield',
                            name: 'uuid',
                            submitValue: false,
                            fieldLabel: 'UUID',
                            anchor: '100%'
                        }
                    ]
                },
                {
                    xtype: 'fieldset',
                    collapsible: true,
                    title: 'Description',
                    anchor: '-15',
                    items: [
                        {
                            xtype: 'textareafield',
                            name: 'description',
                            allowBlank: false,
                            grow: true,
                            growMin: 80,
                            anchor: '100%'
                        }
                    ]
                },
                {
                    xtype: 'fieldset',
                    collapsible: true,
                    title: 'Abstract',
                    anchor: '-15',
                    items: [
                        {
                            xtype: 'textareafield',
                            name: 'abstract',
                            allowBlank: false,
                            grow: true,
                            growMin: 80,
                            anchor: '100%'
                        }
                    ]
                },
                {
                    xtype: 'fieldset',
                    collapsible: true,
                    title: 'Purpose',
                    anchor: '-15',
                    items: [
                        {
                            xtype: 'textareafield',
                            name: 'purpose',
                            grow: true,
                            growMin: 80,
                            anchor: '100%'
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
