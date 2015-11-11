/**
 * Contact details tab panel
 */

Ext.define('PTS.view.contact.tab.ContactTabDetail', {
    extend: 'Ext.tab.Panel',
    alias: 'widget.contacttabdetail',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid',
        'PTS.view.contact.GroupDDList',
        'PTS.view.contact.PersonDDList'
    ],

    title: 'Contact Details',
    activeTab: 0,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            style: {
                backgroundColor: '#FFF',
                backgroundImage: 'none'
            },
            defaults: {
                //autoScroll: true
                layout: 'fit'
            },
            items: [{
                xtype: 'gridpanel',
                itemId: 'contactProjects',
                title: 'Projects',
                store: 'ContactProjects',
                //uri: 'projectcontactfull',
                dockedItems: [{
                    xtype: 'pagingtoolbar',
                    store: 'ContactProjects', // same store GridPanel is using
                    dock: 'top',
                    displayInfo: true,
                    plugins: [
                        Ext.create('Ext.ux.grid.PrintGrid', {
                            printHidden: true
                        }),
                        Ext.create('Ext.ux.grid.SaveGrid', {})
                    ]
                }],
                columns: [{
                        xtype: 'gridcolumn',
                        dataIndex: 'projectcode',
                        text: 'Project'
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'shorttitle',
                        text: 'Short Title',
                        flex: 2
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'role',
                        flex: 1,
                        text: 'Role'
                    }

                ]
            }, {
                xtype: 'panel',
                itemId: 'contactLists',
                getStore: function() {
                    return this.getLayout().getActiveItem().getStore();
                },
                title: 'Contacts',
                style: {
                    borderWidth: '1px 0 0 1px',
                    padding: 0
                },
                activeItem: 1,
                layout: {
                    type: 'card'
                },
                defaults: {
                    autoScroll: true,
                    border: 0
                },
                items: [{
                    xtype: 'gridpanel',
                    itemId: 'personsList',
                    //title: 'Persons',
                    store: 'PersonGroups',
                    uri: 'grouppersonfull',
                    columns: [{
                        xtype: 'gridcolumn',
                        dataIndex: 'firstname',
                        text: 'First Name'
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'lastname',
                        text: 'Last Name'
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'position',
                        text: 'Position',
                        flex: 1
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'groupname',
                        flex: 1,
                        text: 'Name'
                    }]
                }, {
                    xtype: 'gridpanel',
                    itemId: 'groupsList',
                    //title: 'Groups',
                    store: 'PersonGroups',
                    uri: 'grouppersonfull',
                    columns: [{
                        xtype: 'gridcolumn',
                        dataIndex: 'groupfullname',
                        flex: 2,
                        text: 'Full Name'
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'acronym',
                        text: 'Acronym'
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'position',
                        text: 'Position',
                        flex: 1
                    }, {
                        xtype: 'gridcolumn',
                        dataIndex: 'groupname',
                        flex: 1,
                        text: 'Name',
                        hidden: true
                    }]
                }]
            }]
        });

        me.callParent(arguments);
    }
});
