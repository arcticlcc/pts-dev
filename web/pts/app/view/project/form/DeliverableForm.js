/**
 * File: app/view/project/form/DeliverableForm.js
 * Form for editing Deliverable information.
 */

Ext.define('PTS.view.project.form.DeliverableForm', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.deliverableform',
    requires: [
        'PTS.view.controls.ManagerCombo',
        'PTS.view.controls.StatusCombo',
        'PTS.view.controls.RowEditGrid',
        'PTS.view.controls.CommentEditGrid'
    ],

    itemId: 'itemCard-30',
    title: 'Deliverable',
    layout: 'border',
    defaults: {
        trackResetOnLoad: true,
        autoScroll: true,
        preventHeader: true
    },
    //model: 'PTS.model.Deliverable',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'form',
                itemId: 'itemForm',
                model: 'PTS.model.Deliverable',
                layout:'anchor',
                region: 'center',
                bodyPadding: 10,
                items: [
                    {
                        xtype: 'container',
                        itemId: 'mainCon',
                        layout: {
                            type: 'anchor'
                        },
                        anchor: '100%',
                        defaults: {
                            allowBlank: false
                        },
                        items: [
                            {
                                xtype: 'textfield',
                                name: 'title',
                                fieldLabel: 'Title',
                                anchor: '100%'
                            },
                            {
                                xtype: 'textareafield',
                                name: 'description',
                                fieldLabel: 'Description',
                                grow: true,
                                anchor: '100%'
                            },
                            {
                                xtype: 'combobox',
                                name: 'deliverabletypeid',
                                fieldLabel: 'Type',
                                anchor: '100%',
                                store: 'DeliverableTypes',
                                displayField: 'type',
                                valueField: 'deliverabletypeid',
                                forceSelection: true,
                                queryMode: 'local',
                                listConfig: {
                                    getInnerTpl: function() {
                                        return '<div data-qtip="{description}">{type}</div>';
                                    }
                                }
                            }
                        ]
                    },
                    {
                        xtype: 'managercombo'
                    },
                    {
                        xtype: 'datefield',
                        name: 'duedate',
                        fieldLabel: 'Date Due',
                        allowBlank: false
                    },
                    {
                        xtype: 'datefield',
                        name: 'receiveddate',
                        fieldLabel: 'Date Received'
                    },
                    {
                        xtype: 'checkboxfield',
                        name: 'invalid',
                        fieldLabel: 'Invalid',
                        anchor: '100%'
                    },
                    {
                        xtype: 'checkboxgroup',
                        fieldLabel: 'Publication',
                        columns: [
                            100,
                            100
                        ],
                        anchor: '100%',
                        items: [
                            {
                                xtype: 'checkboxfield',
                                name: 'publish',
                                boxLabel: 'Publishable'
                            },
                            {
                                xtype: 'checkboxfield',
                                name: 'restricted',
                                boxLabel: 'Restricted',
                                listeners: {
                                    change: function(f, newval, old) {
                                        f.up('form').down('field[name=accessdescription]').validate();
                                    }
                                }
                            }
                        ]
                    },
                    {
                        xtype: 'textareafield',
                        name: 'accessdescription',
                        fieldLabel: 'Access Description',
                        grow: true,
                        anchor: '100%',
                        validator: function(val) {
                            var r = this.up('form').down('checkboxfield[name=restricted]');

                            if(!r.getValue() || r.getValue() === !!val) {
                                return true;
                            }
                            return 'Access Description is required when publication is restricted';
                        }
                    }
                ]
            },{
                xtype:'tabpanel',
                //disabled:true,
                itemId: 'relatedDetails',
                title: 'Details',
                region: 'south',
                collapsible: true,
                animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                split: true,
                //activeTab: 1,
                flex: 1,
                defaults: {
                    bodyStyle:'padding:10px',
                    disabled: true
                },
                items:[{
                    xtype: 'roweditgrid',
                    store: 'DeliverableModStatuses',
                    uri: 'deliverablemodstatus',
                    title:'Status',
                    disabled: false,
                    columns: [
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'deliverablestatusid',
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
                                xtype: 'statuscombo',
                                store: 'DeliverableStatuses',
                                valueField: 'deliverablestatusid',
                                allowBlank: false
                            },
                            text: 'Status'
                        },
                        {
                            xtype: 'datecolumn',
                            dataIndex: 'effectivedate',
                            editor: {
                                xtype: 'datefield',
                                allowBlank: false
                            },
                            text: 'Effective Date'
                        },
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'contactid',
                            //width: 150,
                            hidden: false,
                            renderer: function(value) {
                                var store = Ext.getStore('GroupUsers'),
                                    idx = store.find('contactid', value, 0, false, true, true),
                                    rec = store.getAt(idx);
                                if (rec) {
                                    return rec.get('fullname');
                                }
                                return value;
                            },
                            text: 'User'
                        },
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'comment',
                            editor: {
                                xtype: 'textfield'
                            },
                            flex: 1,
                            text: 'Comment'
                        }
                    ]
                }, {
                    title:'Contacts'
                },{
                    title:'Progress'
                },{
                    title: 'Comments',
                    disabled: false,
                    xtype: 'commenteditgrid',
                    store: 'DeliverableComments',
                    uri: 'deliverablecomment'
                }]
            }]
        });

        me.callParent(arguments);
    }
});
