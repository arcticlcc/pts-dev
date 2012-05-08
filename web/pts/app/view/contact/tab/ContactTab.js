/*
 * File: app/view/contact/tab/ContactTab.js
 * Description: Contact Manager
 */

Ext.define('PTS.view.contact.tab.ContactTab', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.contacttab',
    requires: [
        'PTS.view.contact.PersonList',
        'PTS.view.contact.GroupList'/*,
        'ArcticPTS.view.ContactDetailsTabPanel',*/
    ],

    border: 0,
    layout: {
        type: 'border'
    },
    title: 'Contacts',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            dockedItems: [
                {
                    xtype: 'toolbar',
                    //id: 'alccProjectToolbar',
                    //region: 'center',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'button',
                            iconCls: 'pts-menu-add',
                            text: 'Add Contact',
                            itemId: 'newcontactbtn',
                            action: 'addcontact'
                        },
                        {
                            xtype: 'button',
                            iconCls: 'pts-menu-edit',
                            text: 'Edit Contact',
                            itemId: 'editcontactbtn',
                            action: 'editcontact',
                            disabled: true
                        }
                    ]
                }
            ],
            items: [
                {
                    xtype: 'tabpanel',
                    border: 0,
                    itemId: 'contactList',
                    activeTab: 0,
                    flex: 1,
                    region: 'center',
                    items: [
                        {
                            xtype: 'personlist',//'persongrid',
                            title: 'Person'
                        },
                        {
                            xtype: 'grouplist',
                            title: 'Group'
                            //store: 'GroupStore'
                        }
                    ]
                },
                {
                    xtype: 'panel',
                    border: 0,
                    width: 150,
                    layout: {
                        type: 'border'
                    },
                    bodyStyle: {
                        border: 'none',
                        backgroundColor: '#FFF',
                        backgroundImage: 'none'
                    },
                    collapsible: true,
                    animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                    preventHeader: true,
                    title: 'Contact Details',
                    flex: 1,
                    region: 'east',
                    split: true,
                    items: [
                        {
                            xtype: 'panel',//'contactdetailstabpanel',
                            region: 'center'
                            //id: 'alcc-contactdetails-tp'
                        },
                        {
                            xtype: 'form',
                            collapsible: true,
                            animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                            title: 'Search',
                            titleCollapse: true,
                            flex: 1,
                            region: 'south',
                            split: true
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
