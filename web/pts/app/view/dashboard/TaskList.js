/**
 * File: app/view/dashboard/Tasklist.js
 * Description: Dashboard grid showing tasks.
 */

Ext.define('PTS.view.dashboard.TaskList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.tasklist',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid'
    ],

    autoScroll: true,
    title: 'Tasks',
    store: 'Tasks',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            viewConfig: {

            },
            dockedItems: [
                    {
                        xtype: 'pagingtoolbar',
                        store: 'Tasks',   // same store GridPanel is using
                        dock: 'top',
                        displayInfo: true,
                        plugins: [
                            Ext.create('Ext.ux.grid.PrintGrid', {
                                title: function(){
                                    return this.child('cycle#filter').getActiveItem().text + ' (Tasks)';
                                }
                            }),
                            Ext.create('Ext.ux.grid.SaveGrid', {})
                        ],
                        items: [
                            '-',
                            {
                                xtype: 'cycle',
                                itemId: 'filter',
                                showText: true,
                                action: 'filtertask',
                                tooltip: 'Click to filter the Tasks',
                                menu: {
                                    xtype: 'menu',
                                    width: 120,
                                    items: [
                                        {
                                            //xtype: 'menucheckitem',
                                            iconCls: 'pts-menu-users',
                                            text: 'Show All',
                                            filter: 'all'
                                        },
                                        {
                                            //xtype: 'menucheckitem',
                                            iconCls: 'pts-menu-user',
                                            text: 'Show Mine',
                                            filter: 'user'
                                        },
                                        {
                                            //xtype: 'menucheckitem',
                                            iconCls: 'pts-menu-exclamation',
                                            text: 'Due Today',
                                            filter: 'today'
                                        }
                                    ]
                                }
                            },
                            '-',
                            {
                                xtype: 'button',
                                action: 'togglecomplete',
                                text: 'Completed',
                                enableToggle: 'true',
                                iconCls: 'pts-btn-check',
                                tooltip: 'Include completed tasks'
                            }
                        ]
                    }
            ],
            columns: [
                {
                    xtype: 'datecolumn',
                    width: 83,
                    dataIndex: 'duedate',
                    text: 'Due Date'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'assignee',
                    text: 'Assignee'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'title',
                    flex: 1,
                    text: 'Title'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'status',
                    //hidden: true,
                    text: 'Status'
                }
            ]
        });

        me.callParent(arguments);
    }
});
