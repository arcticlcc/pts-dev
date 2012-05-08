/**
 * File: app/view/project/form/DeliverableForm.js
 * Form for editing Deliverable information.
 */

Ext.define('PTS.view.project.form.DeliverableForm', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.deliverableform',
    requires: ['PTS.view.controls.ManagerCombo'],

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
                                allowBlank: false,
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
                title: 'Details',
                region: 'south',
                collapsible: true,
                animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                split: true,
                activeTab: 0,
                flex: 1,
                defaults: {
                    bodyStyle:'padding:10px',
                    disabled: true
                },
                items:[{
                    title:'Contacts'
                },{
                    title:'Progress'
                },{
                    title: 'Comments'
                }]
            }]
        });

        me.callParent(arguments);
    }
});
