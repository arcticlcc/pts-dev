/**
 * File: app/view/project/form/ProposalForm.js
 * Form for editing proposal information.
 */

Ext.define('PTS.view.project.form.ProposalForm', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.proposalform',
    requires: [
        'PTS.view.controls.ManagerCombo',
        'PTS.view.controls.StatusCombo'
    ],

    itemId: 'itemCard-10',
    ptsConfirmDelete: true,
    title: 'Proposal',
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
                layout:'anchor',
                region: 'center',
                bodyPadding: 10,
                defaults: {
                    anchor: '100%'
                },
                items: [
                    {
                        xtype: 'datefield',
                        name: 'datecreated',
                        fieldLabel: 'Received',
                        allowBlank: false
                    },
                    {
                        xtype: 'combobox',
                        name: 'personid',
                        fieldLabel: 'Manager',
                        //anchor: '50%',
                        store: 'GroupUsers',
                        displayField: 'fullname',
                        valueField: 'contactid',
                        forceSelection: true,
                        allowBlank: false,
                        queryMode: 'local'
                    },
                    {
                        xtype: 'combobox',
                        name: 'modtypeid',
                        fieldLabel: 'Type',
                        store: 'ProposalTypes',
                        displayField: 'type',
                        valueField: 'modtypeid',
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
                        xtype: 'textfield',
                        name: 'modificationcode',
                        fieldLabel: 'Proposal #'
                    },
                    {
                        xtype: 'textfield',
                        name: 'title',
                        fieldLabel: 'Title',
                        emptyText: 'Title',
                        maxLength: 250,
                        enforceMaxLength: true,
                        allowBlank: false
                    },
                    {
                        xtype: 'textfield',
                        name: 'shorttitle',
                        fieldLabel: 'Short Title',
                        emptyText: 'Short Title',
                        maxLength: 60,
                        enforceMaxLength: true,
                        allowBlank: false
                    },
                    {
                        xtype: 'textareafield',
                        name: 'description',
                        fieldLabel: 'Description',
                        allowBlank: false,
                        grow: true
                    }
                ]
            },{
                xtype:'tabpanel',
                disabled:true,
                itemId: 'relatedDetails',
                title: 'Details',
                region: 'south',
                collapsible: true,
                animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                split: true,
                activeTab: 0,
                flex: 1,
                defaults:{bodyStyle:'padding:10px'},
                items:[{
                    xtype: 'roweditgrid',
                    store: 'ModStatuses',
                    uri: 'modstatus',
                    title:'Status',
                    columns: [
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'statusid',
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
                                xtype: 'statuscombo'
                            },
                            text: 'Status'
                        },
                        {
                            xtype: 'datecolumn',
                            dataIndex: 'effectivedate',
                            editor: {
                                xtype: 'datefield'
                            },
                            text: 'Effective Date'
                        },
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'comment',
                            editor: {
                                xtype: 'textfield'
                            },
                            flex: 2,
                            text: 'Comment'
                        }
                    ]
                },{
                    title:'Contacts',
                    disabled: true
                },{
                    title: 'Comments',
                    disabled: true
                }]
            }]
        });

        me.callParent(arguments);
    }
});
