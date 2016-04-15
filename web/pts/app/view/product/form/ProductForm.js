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
    submitEmptyText: false,

    initComponent: function() {
        var me = this;

        me.initialConfig = Ext.apply({
            trackResetOnLoad: true
        }, me.initialConfig);

        Ext.applyIf(me, {
            dockedItems: [{
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
                    }, {
                        xtype: 'button',
                        text: 'Save',
                        iconCls: 'pts-menu-savebasic',
                        action: 'saveproduct',
                        formBind: true
                    }, {
                        xtype: 'button',
                        text: 'Reset',
                        iconCls: 'pts-menu-reset',
                        //disabled: true,
                        action: 'resetproduct'
                    }
                ]
            }],
            items: [{
                xtype: 'fieldset',
                title: 'Product',
                anchor: '-15',
                items: [{
                        xtype: 'checkboxfield',
                        name: 'isgroup',
                        //margin: '0 0 0 20',
                        width: 175,
                        boxLabel: 'Is Group?',
                        labelPad: 3,
                        labelWidth: 120
                    },{
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
                        forceSelection: false,
                        allowBlank: true,
                        //queryMode: 'local',
                        fieldLabel: 'Project',
                        displayField: 'projectcode',
                        listConfig: {
                            getInnerTpl: function() {
                                return '<div>{projectcode}: {shorttitle}</div>';
                            }
                        },
                        store: 'ProjectIDs',
                        valueField: 'projectid',
                        anchor: '100%',
                        queryParam: 'filter'
                    }, {
                        xtype: 'combobox',
                        name: 'productgroupid',
                        forceSelection: true,
                        allowBlank: true,
                        //queryMode: 'local',
                        fieldLabel: 'Product Group',
                        displayField: 'title',
                        listConfig: {
                            getInnerTpl: function() {
                                return '<div>{projectcode}: {title}</div>';
                            }
                        },
                        store: 'ProductGroupIDs',
                        valueField: 'productid',
                        anchor: '100%',
                        queryParam: 'filter'
                    }, {
                        xtype: 'combobox',
                        name: 'deliverabletypeid',
                        fieldLabel: 'Type',
                        allowBlank: true,
                        anchor: '50%',
                        store: 'ProductTypes',
                        displayField: 'type',
                        valueField: 'deliverabletypeid',
                        forceSelection: true,
                        queryMode: 'local',
                        listConfig: {
                            getInnerTpl: function() {
                                return '<div data-qtip="{description}">{type}</div>';
                            }
                        }
                    }, {
                        xtype: 'combobox',
                        name: 'isoprogresstypeid',
                        fieldLabel: 'Progress',
                        allowBlank: false,
                        anchor: '50%',
                        store: 'IsoProgressTypes',
                        displayField: 'codename',
                        valueField: 'isoprogresstypeid',
                        forceSelection: true,
                        queryMode: 'local',
                        listConfig: {
                            getInnerTpl: function() {
                                return '<div data-qtip="{description}">{codename}</div>';
                            }
                        }
                    }, {
                        xtype: 'fieldcontainer',
                        layout: {
                            type: 'anchor'
                        },
                        fieldLabel: 'Time Period',
                        items: [{
                            xtype: 'daterangefield',
                            itemId: 'startDate',
                            name: 'startdate',
                            fieldLabel: 'Start',
                            allowBlank: true,
                            vfield: 'beginDate',
                            endDateField: 'endDate',
                            vtype: 'daterange',
                            labelWidth: 70
                        }, {
                            xtype: 'daterangefield',
                            itemId: 'endDate',
                            name: 'enddate',
                            allowBlank: true,
                            vfield: 'endDate',
                            startDateField: 'startDate',
                            vtype: 'daterange',
                            fieldLabel: 'End',
                            labelWidth: 70
                        },{
                          xtype: 'textfield',
                          name: 'perioddescription',
                          fieldLabel: 'Description',
                          anchor: '75%',
                          labelWidth: 70
                        }]
                      }, {
                          xtype: 'combobox',
                          name: 'maintenancefrequencyid',
                          fieldLabel: 'Maintenance Frequency',
                          allowBlank: true,
                          anchor: '50%',
                          store: 'MaintenanceFrequencies',
                          displayField: 'codename',
                          valueField: 'maintenancefrequencyid',
                          forceSelection: true,
                          queryMode: 'local',
                          listConfig: {
                              getInnerTpl: function() {
                                  return '<div data-qtip="{description}">{codename}</div>';
                              }
                          }
                    }, {
                        xtype: 'displayfield',
                        name: 'uuid',
                        submitValue: false,
                        fieldLabel: 'UUID',
                        anchor: '100%'
                    }
                ]
            }, {
                xtype: 'fieldset',
                collapsible: true,
                title: 'Description',
                anchor: '-15',
                items: [{
                    xtype: 'textareafield',
                    name: 'description',
                    allowBlank: false,
                    grow: true,
                    growMin: 80,
                    anchor: '100%'
                }]
            }, {
                xtype: 'fieldset',
                collapsible: true,
                title: 'Abstract',
                anchor: '-15',
                items: [{
                    xtype: 'textareafield',
                    name: 'abstract',
                    allowBlank: false,
                    grow: true,
                    growMin: 80,
                    anchor: '100%'
                }]
            }, {
                xtype: 'fieldset',
                collapsible: true,
                title: 'Purpose',
                anchor: '-15',
                items: [{
                    xtype: 'textareafield',
                    name: 'purpose',
                    grow: true,
                    growMin: 80,
                    anchor: '100%'
                }]
            }, {
                xtype: 'fieldset',
                collapsible: true,
                  title: 'Use Limitation',
                anchor: '-15',
                items: [{
                    xtype: 'textareafield',
                    name: 'uselimitation',
                    grow: true,
                    growMin: 80,
                    anchor: '100%'
                }]
            }]
        });

        me.callParent(arguments);
    }
});
