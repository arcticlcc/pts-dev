/**
 * File: app/view/project/form/ProjectForm.js
 * Form for editing basic project information.
 */

Ext.define('PTS.view.project.form.ProjectForm', {
    extend: 'Ext.form.Panel',
    alias: 'widget.projectform',
    requires: [
        'PTS.view.controls.DateRangeField',
        'PTS.view.controls.SimpleLink',
        'Ext.form.field.Display'

    ],

    autoScroll: true,
    bodyPadding: 5,
    title: 'Project',

    initComponent: function() {
        var me = this;

        me.initialConfig = Ext.apply({
            trackResetOnLoad: true
        }, me.initialConfig);

        Ext.applyIf(me, {
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                    xtype: 'button',
                    text: 'Edit',
                    iconCls: 'pts-menu-editbasic',
                    hidden: true,
                    action: 'editproject'
                }, {
                    xtype: 'button',
                    text: 'Delete',
                    iconCls: 'pts-menu-deletebasic',
                    //disabled: true,
                    action: 'deleteproject'
                }, {
                    xtype: 'button',
                    text: 'Save',
                    iconCls: 'pts-menu-savebasic',
                    formBind: true,
                    action: 'saveproject'
                }, {
                    xtype: 'button',
                    text: 'Reset',
                    iconCls: 'pts-menu-reset',
                    //disabled: true,
                    action: 'resetproject'
                }]
            }],
            items: [{
                xtype: 'fieldset',
                title: 'Project',
                anchor: '-15',
                items: [{
                    xtype: 'fieldcontainer',
                    minWidth: 400,
                    layout: {
                        align: 'stretchmax',
                        type: 'hbox'
                    },
                    combineErrors: true,
                    fieldLabel: 'Project ID',
                    items: [{
                            xtype: 'displayfield',
                            padding: '0 35 0 0',
                            value: PTS.orgcode,
                            hideLabel: true
                        }, {
                            xtype: 'numberfield',
                            width: 75,
                            name: 'fiscalyear',
                            value: 2012,
                            fieldLabel: 'Fiscal Year',
                            hideLabel: true,
                            labelAlign: 'right',
                            labelPad: 3,
                            labelSeparator: '',
                            labelWidth: 35,
                            allowBlank: false,
                            emptyText: 'Fiscal Year',
                            allowDecimals: false,
                            hideTrigger: true
                        }, {
                            xtype: 'displayfield',
                            margin: '0 2',
                            value: '--',
                            hideLabel: true
                        }, {
                            xtype: 'textfield',
                            width: 150,
                            name: 'number',
                            fieldLabel: 'Project ID',
                            hideLabel: true,
                            labelAlign: 'right',
                            labelSeparator: '',
                            labelWidth: 8,
                            allowBlank: false,
                            emptyText: 'Unique ID'
                        }
                        /*,
                                                        {
                                                            xtype: 'checkboxfield',
                                                            name: 'exportmetadata',
                                                            margin: '0 0 0 20',
                                                            width: 175,
                                                            boxLabel: 'Export Metadata?',
                                                            labelPad: 3,
                                                            labelWidth: 120
                                                        }*/
                    ]
                }, {
                    xtype: 'textfield',
                    name: 'title',
                    fieldLabel: 'Title',
                    allowBlank: false,
                    emptyText: 'Project Title',
                    maxLength: 150,
                    enforceMaxLength: true,
                    anchor: '100%'
                }, {
                    xtype: 'textfield',
                    name: 'shorttitle',
                    fieldLabel: 'Short Title',
                    allowBlank: false,
                    emptyText: 'Short Title',
                    maxLength: 60,
                    enforceMaxLength: true,
                    anchor: '60%'
                }, {
                    xtype: 'combobox',
                    name: 'parentprojectid',
                    fieldLabel: 'Parent Project',
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
                    xtype: 'fieldcontainer',
                    layout: {
                        type: 'anchor'
                    },
                    fieldLabel: 'Dates',
                    items: [{
                        xtype: 'daterangefield',
                        itemId: 'startDate',
                        name: 'startdate',
                        fieldLabel: 'Start',
                        allowBlank: false,
                        vfield: 'beginDate',
                        endDateField: 'endDate',
                        vtype: 'daterange',
                        labelWidth: 50
                    }, {
                        xtype: 'daterangefield',
                        itemId: 'endDate',
                        name: 'enddate',
                        allowBlank: false,
                        vfield: 'endDate',
                        startDateField: 'startDate',
                        vtype: 'daterange',
                        fieldLabel: 'End',
                        labelWidth: 50
                    }]
                }, {
                    xtype: 'displayfield',
                    name: 'uuid',
                    submitValue: false,
                    fieldLabel: 'UUID',
                    anchor: '100%'
                },
                {
                    xtype: 'fieldcontainer',
                    layout: {
                        align: 'stretchmax',
                        type: 'hbox'
                    },
                    fieldLabel: 'ScienceBase ID',
                    items: [{
                        xtype: 'textfield',
                        name: 'sciencebaseid',
                        allowBlank: true,
                        emptyText: 'ScienceBase ID',
                        hideLabel: true,
                        width: 300
                    }, {
                        xtype: 'simplelink',
                        text: 'View in ScienceBase',
                        margin: '0 10',
                        cls: 'x-form-item-label',
                        handler: function () {
                            window.open('https://www.sciencebase.gov/catalog/item/' +
                                this.prev('textfield[name=sciencebaseid]')
                                .value, '_sb');
                        }
                    }]
                }]
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
                title: 'Supplemental',
                anchor: '-15',
                items: [{
                    xtype: 'textareafield',
                    name: 'supplemental',
                    grow: true,
                    growMin: 80,
                    anchor: '100%'
                }]
            }]
        });

        me.callParent(arguments);
    }
});
