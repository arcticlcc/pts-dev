/**
 * File: app/view/project/form/AgreementForm.js
 * Form for editing Agreement information.
 */

Ext.define('PTS.view.project.form.AgreementForm', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.agreementform',
    requires: [
        'PTS.view.controls.ManagerCombo',
        'PTS.view.controls.StatusCombo',
        'PTS.view.controls.RowEditGrid',
        'Ext.form.field.VTypes',
        'PTS.view.controls.CommentEditGrid'
    ],

    itemId: 'itemCard-20',
    ptsConfirmDelete: true,
    title: 'Agreement',
    layout: 'border',
    defaults: {
        trackResetOnLoad: true,
        autoScroll: true,
        preventHeader: true
    },
    //model: 'PTS.model.Modification',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'form',
                itemId: 'itemForm',
                model: 'PTS.model.Modification',
                layout: 'anchor',
                region: 'center',
                bodyPadding: 10,
                items: [{
                    xtype: 'fieldcontainer',
                    layout: {
                        align: 'stretchmax',
                        type: 'hbox'
                    },
                    margin: '0 0 10 0',
                    combineErrors: false,
                    fieldLabel: 'Period',
                    items: [{
                        xtype: 'daterangefield',
                        itemId: 'startDate',
                        margin: '0 20 0 0',
                        name: 'startdate',
                        fieldLabel: 'Start',
                        vfield: 'beginDate',
                        endDateField: 'endDate',
                        vtype: 'daterange',
                        labelWidth: 45,
                        width: 150
                    }, {
                        xtype: 'datefield',
                        itemId: 'endDate',
                        name: 'enddate',
                        fieldLabel: 'End',
                        startDateField: 'startDate',
                        vfield: 'endDate',
                        vtype: 'daterange',
                        labelWidth: 40,
                        width: 150
                    }]
                }, {
                    xtype: 'fieldcontainer',
                    itemId: 'modcodeCon',
                    //minWidth: 400,
                    hidden: true,
                    layout: {
                        align: 'stretchmax',
                        type: 'hbox'
                    },
                    combineErrors: true,
                    fieldLabel: 'Agreement #',
                    items: [{
                        xtype: 'displayfield',
                        padding: '0 35 0 0',
                        name: 'parentcode',
                        hideLabel: true,
                        width: 85,
                        valueToRaw: function(value) {
                            return Ext.String.ellipsis(value, 14);
                        }
                    }, {
                        xtype: 'displayfield',
                        name: 'codedelimiter',
                        margin: '0 2',
                        width: 5,
                        value: '/',
                        hideLabel: true
                    }, {
                        xtype: 'textfield',
                        name: 'modcode',
                        width: 150,
                        submitValue: false,
                        hideLabel: true,
                        validator: function(val) {
                            if (this.isVisible(true) !== true || val.length > 0) {
                                return true;
                            } else {
                                return 'You must enter a number for Modifications.';
                            }
                        }
                    }]
                }, {
                    xtype: 'textfield',
                    name: 'modificationcode',
                    fieldLabel: 'Agreement #',
                    anchor: '100%'
                }, {
                    xtype: 'textfield',
                    name: 'title',
                    fieldLabel: 'Title',
                    allowBlank: false,
                    anchor: '100%'
                }, {
                    xtype: 'managercombo',
                    allowBlank: false
                }, {
                    xtype: 'combobox',
                    name: 'modtypeid',
                    fieldLabel: 'Type',
                    store: 'AgreementTypes',
                    displayField: 'type',
                    valueField: 'modtypeid',
                    forceSelection: true,
                    allowBlank: false,
                    queryMode: 'local',
                    listConfig: {
                        getInnerTpl: function() {
                            return '<div data-qtip="{description}">{type}</div>';
                        }
                    },
                    anchor: '50%'
                }, {
                    xtype: 'textareafield',
                    name: 'description',
                    fieldLabel: 'Description',
                    grow: true,
                    allowBlank: false,
                    anchor: '100%'
                }]
            }, {
                xtype: 'tabpanel',
                disabled: true,
                itemId: 'relatedDetails',
                title: 'Details',
                region: 'south',
                collapsible: true,
                animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                split: true,
                activeTab: 0,
                flex: 1,
                defaults: {
                    bodyStyle: 'padding:10px'
                },
                items: [{
                    xtype: 'roweditgrid',
                    store: 'ModStatuses',
                    itemId: 'statusGrid',
                    uri: 'modstatus',
                    title: 'Status',
                    columns: [{
                        xtype: 'gridcolumn',
                        dataIndex: 'statusid',
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
                            xtype: 'statuscombo',
                            allowBlank: false
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
                        dataIndex: 'comment',
                        editor: {
                            xtype: 'textfield'
                        },
                        flex: 2,
                        text: 'Comment'
                    }]
                }, {
                    xtype: 'roweditgrid',
                    store: 'PurchaseRequests',
                    uri: 'purchaserequest',
                    title: 'PPR Reference #',
                    columns: [{
                        header: 'Reference #',
                        dataIndex: 'purchaserequest',
                        sortable: true,
                        hideable: false,
                        flex: 1,
                        editor: {
                            xtype: 'textfield',
                            allowBlank: false
                        }
                    }, {
                        header: 'Comment',
                        dataIndex: 'comment',
                        flex: 2,
                        editor: {
                            xtype: 'textfield'
                        }
                    }]
                }, {
                    title: 'Contacts',
                    disabled: true
                }, {
                    title: 'Comments',
                    disabled: false,
                    xtype: 'commenteditgrid',
                    store: 'ModificationComments',
                    uri: 'modcomment'
                }]
            }]
        });

        me.callParent(arguments);
    }
});
