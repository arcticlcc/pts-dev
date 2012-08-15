/**
 *
 * Panel for editing basic contact information. Includes person and contactgroup forms.
 */

Ext.define('PTS.view.contact.window.ContactForm', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.contactform',
    requires: [
        'PTS.view.contact.window.ContactDetail',
        'PTS.view.contact.window.PersonGroups',
        'PTS.view.contact.window.ContactToolbar',
        'PTS.view.controls.PositionCombo'
    ],
    /*autoScroll: true,
    bodyPadding: 5,*/
    activeItem: 0,
    layout: {
        type: 'card'
    },
    title: 'Edit Contact',
    preventHeader: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            defaults: {
                preventHeader: true
            },
            items: [
                {
                    xtype: 'tabpanel',
                    itemId:'person',
                    activeTab: 0,
                    items: [
                        {
                            xtype: 'form',
                            itemId:'personForm',
                            autoScroll: true,
                            bodyPadding: 10,
                            title: 'Person',
                            trackResetOnLoad: true,
                            dockedItems: [
                                {
                                    xtype: 'contacttoolbar'
                                }
                            ],
                            items: [
                                {
                                    xtype: 'checkboxfield',
                                    name: 'inactive',
                                    //style: 'textAlign:right',
                                    anchor: '100%',
                                    fieldLabel: 'Inactive?',
                                    hideLabel: true,
                                    boxLabel: 'Inactive?',
                                    boxLabelAlign: 'before'
                                },
                                {
                                    xtype: 'fieldcontainer',
                                    defaults: {
                                        hideLabel: true
                                    },
                                    layout: {
                                        defaultMargins: {
                                            'top': 0,
                                            right: 5,
                                            bottom: 0,
                                            left: 0
                                        },
                                        type: 'hbox'
                                    },
                                    combineErrors: true,
                                    fieldLabel: 'Name',
                                    msgTarget: 'side',
                                    anchor: '100%',
                                    items: [
                                        {
                                            xtype: 'textfield',
                                            name: 'firstname',
                                            fieldLabel: 'First Name',
                                            allowBlank: false,
                                            emptyText: 'First',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'textfield',
                                            name: 'middlename',
                                            fieldLabel: 'Middle Name',
                                            emptyText: 'Middle',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'textfield',
                                            name: 'lastname',
                                            fieldLabel: 'Last Name',
                                            allowBlank: false,
                                            emptyText: 'Last',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'textfield',
                                            width: 65,
                                            name: 'suffix',
                                            fieldLabel: 'Suffix',
                                            emptyText: 'Suffix'
                                        }
                                    ]
                                },
                                {
                                    xtype: 'positioncombo',
                                    name: 'positionid',
                                    anchor: '50%'
                                },
                                {
                                    xtype: 'combobox',
                                    anchor: '50%',
                                    name: 'contacttypeid',
                                    fieldLabel: 'Type',
                                    store: 'ContactTypes',
                                    displayField: 'title',
                                    valueField: 'contacttypeid',
                                    forceSelection: true,
                                    allowBlank: false,
                                    queryMode: 'local',
                                    listConfig: {
                                        getInnerTpl: function() {
                                            return '<div data-qtip="{description}">{title}</div>';
                                        }
                                    }
                                },
                                {
                                    xtype: 'textfield',
                                    name: 'dunsnumber',
                                    fieldLabel: 'DUNS #',
                                    anchor: '100%'
                                },
                                {
                                    xtype: 'contactdetail'
                                },
                                {
                                    xtype: 'textareafield',
                                    name: 'comment',
                                    fieldLabel: 'Comment',
                                    grow: true,
                                    growMax: 100,
                                    growMin: 80,
                                    anchor: '100%'
                                }
                            ]
                        }/*,
                        {
                            xtype: 'persongroups',
                            itemId: 'personGroups',
                            title: 'Manage Groups'
                        }*/
                    ]
                },
                {
                    xtype: 'tabpanel',
                    itemId:'group',
                    activeTab: 0,
                    items: [
                    {
                        xtype: 'form',
                        itemId:'groupForm',
                        autoScroll: true,
                        bodyPadding: 10,
                        title: 'Group',
                        trackResetOnLoad: true,
                        dockedItems: [
                            {
                                xtype: 'contacttoolbar'
                            }
                        ],
                        items: [
                            {
                                xtype: 'checkboxfield',
                                name: 'inactive',
                                //style: 'textAlign:right',
                                anchor: '100%',
                                fieldLabel: 'Inactive?',
                                hideLabel: true,
                                boxLabel: 'Inactive?',
                                boxLabelAlign: 'before'
                            },
                            {
                                xtype: 'fieldcontainer',
                                layout: {
                                    defaultMargins: {
                                        'top': 0,
                                        right: 15,
                                        bottom: 0,
                                        left: 0
                                    },
                                    type: 'hbox'
                                },
                                combineErrors: true,
                                msgTarget: 'side',
                                anchor: '100%',
                                items: [
                                    {
                                        xtype: 'textfield',
                                        name: 'name',
                                        fieldLabel: 'Name',
                                        allowBlank: false,
                                        flex: 1
                                    },
                                    {
                                        xtype: 'textfield',
                                        width: 165,
                                        name: 'acronym',
                                        fieldLabel: 'Acronym',
                                        allowBlank: false,
                                        labelWidth: 75
                                    },
                                    {
                                        xtype: 'checkboxfield',
                                        name: 'organization',
                                        fieldLabel: 'Organization?',
                                        allowBlank: false,
                                        hideLabel: true,
                                        boxLabel: 'Organization?',
                                        boxLabelAlign: 'before',
                                        inputValue: 'true'
                                    }
                                ]
                            },
                            {
                                xtype: 'combobox',
                                anchor: '50%',
                                name: 'contacttypeid',
                                fieldLabel: 'Type',
                                store: 'ContactTypes',
                                displayField: 'title',
                                valueField: 'contacttypeid',
                                forceSelection: true,
                                allowBlank: false,
                                queryMode: 'local',
                                listConfig: {
                                    getInnerTpl: function() {
                                        return '<div data-qtip="{description}">{title}</div>';
                                    }
                                }
                            },
                            {
                                xtype: 'filtercombo',
                                itemId: 'parentGroup',
                                anchor: '100%',
                                name: 'parentgroupid',
                                fieldLabel: 'Primary Parent',
                                store: 'ContactGroupIDs',
                                displayField: 'fullname',
                                valueField: 'contactid',
                                forceSelection: false,
                                queryMode: 'local',
                                validator: function(val) {
                                    var cid = this.up('form#groupForm').getRecord().getId();

                                    if(cid === this.getValue()) {
                                        return "A group cannot be its own parent";
                                    }else {
                                        return true;
                                    }
                                }/*,
                                remoteFilterField: 'fullname',
                                typeAhead: true,
                                minChars: 2,
                                queryMode: 'local',
                                hideTrigger:true,
                                listConfig: {
                                    loadingText: 'Searching...',
                                    emptyText: 'No matching groups found.'
                                },
                                pageSize: 20*/
                            },
                            {
                                xtype: 'textfield',
                                name: 'dunsnumber',
                                fieldLabel: 'DUNS #',
                                anchor: '100%'
                            },
                            {
                                xtype: 'contactdetail'
                            },
                            {
                                xtype: 'textareafield',
                                name: 'comment',
                                fieldLabel: 'Comment',
                                grow: true,
                                growMax: 100,
                                growMin: 80,
                                anchor: '100%'
                            }
                        ]
                    }/*,
                        {
                            xtype: 'persongroups',
                            itemId: 'groupMembers',
                            title: 'Manage Members'
                        }*/
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
