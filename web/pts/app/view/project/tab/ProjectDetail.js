/**
 * Project details tab panel
 */

Ext.define('PTS.view.project.tab.ProjectDetail', {
    extend: 'Ext.tab.Panel',
    alias: 'widget.projectdetail',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid'
    ],

    title: 'Project Details',
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
                    xtype: 'treepanel',
                    itemId: 'projectAgreements',
                    title: 'Agreements',
                    store: 'ProjectAgreementsTree',
                    uri: 'tree',
                    //cls: 'pts-no-tree-icons',
                    lines: false,
                    useArrows: true,
                    rootVisible: false,
                    viewConfig: {
                        /*getRowClass: function(record, rowIndex, rowParams, store){
                            return record.get("hilite") ? "pts-tree-highlight" : 'pts-tree-header';
                        }*/
                        disableSelection: true
                    },
                    columns: [{
                        xtype: 'treecolumn',
                        dataIndex: 'text',
                        width: 300,
                        text: 'Title'
                    }, {
                        xtype: 'gridcolumn',
                        //align: 'center',
                        dataIndex: 'type',
                        text: 'Type',
                        width: 75
                    }, {
                        xtype: 'gridcolumn',
                        flex: 1,
                        dataIndex: 'code',
                        text: 'Agreement #'
                    }]
                }, {
                    xtype: 'deliverablelist',
                    title: 'Deliverables',
                    store: 'ProjectDeliverables',
                    initFilter: 'all',
                    uri: 'deliverabledue'
                }, {
                    xtype: 'gridpanel',
                    itemId: 'projectContacts',
                    title: 'Contacts',
                    store: 'ProjectContacts',
                    uri: 'projectcontactfull',
                    dockedItems: [{
                        xtype: 'pagingtoolbar',
                        store: 'ProjectContacts', // same store GridPanel is using
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
                            sortable: false,
                            dataIndex: 'name',
                            flex: 1,
                            text: 'Name'
                        }, {
                            xtype: 'gridcolumn',
                            dataIndex: 'role',
                            sortable: false,
                            flex: 1,
                            text: 'Role'
                        }, {
                            xtype: 'booleancolumn',
                            dataIndex: 'partner',
                            sortable: false,
                            text: 'Partner?',
                            width: 55
                        }, {
                            xtype: 'booleancolumn',
                            dataIndex: 'reminder',
                            sortable: false,
                            text: 'Notice?',
                            width: 55
                        }

                    ]
                }
                /*,
                                {
                                    xtype: 'panel',
                                    title: 'Files'
                                }*/
            ]
        });

        me.callParent(arguments);
    }
});
