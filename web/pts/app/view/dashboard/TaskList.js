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

    width: 350,
    autoScroll: true,
    collapsible: true,
    animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
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
                            Ext.create('Ext.ux.grid.PrintGrid', {}),
                            Ext.create('Ext.ux.grid.SaveGrid', {})
                        ],
                        items: [
                            '-',
                            {
                                xtype: 'cycle',
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
                }
            ]
        });

        me.callParent(arguments);
    }
});
