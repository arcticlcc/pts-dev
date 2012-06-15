/**
 * File: app/view/dashboard/Deliverablelist.js
 * Description: Dashboard grid showing deliverables.
 */

Ext.define('PTS.view.dashboard.DeliverableList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.deliverablelist',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid'
    ],

    autoScroll: true,
    title: 'Deliverables',
    store: 'DeliverableListings',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            viewConfig: {

            },
            dockedItems: [
                    {
                        xtype: 'pagingtoolbar',
                        store: 'DeliverableListings',   // same store GridPanel is using
                        dock: 'top',
                        displayInfo: true,
                        plugins: [
                            Ext.create('Ext.ux.grid.PrintGrid', {
                                title: function(){
                                    return this.child('cycle#filter').getActiveItem().text + ' Deliverables';
                                },
                                printHidden: true
                            }),
                            Ext.create('Ext.ux.grid.SaveGrid', {})
                        ],
                        items: [
                            '-',
                            {
                                xtype: 'cycle',
                                itemId: 'filter',
                                showText: true,
                                action: 'filterdeliverable',
                                tooltip: 'Click to filter the Deliverables',
                                menu: {
                                    xtype: 'menu',
                                    width: 120,
                                    items: [
                                        {
                                            //xtype: 'menucheckitem',
                                            iconCls: 'pts-flag-red',
                                            text: 'Overdue',
                                            filter: 'over'
                                        },
                                        {
                                            //xtype: 'menucheckitem',
                                            iconCls: 'pts-flag-orange',
                                            text: 'Due Soon',
                                            filter: 'soon'
                                        },
                                        {
                                            //xtype: 'menucheckitem',
                                            iconCls: 'pts-flag-gray',
                                            text: 'All',
                                            filter: 'all'
                                        },
                                        {
                                            //xtype: 'menucheckitem',
                                            iconCls: 'pts-flag-green',
                                            text: 'Completed',
                                            filter: 'complete'
                                        }
                                    ]
                                }
                            }
                        ]
                    }
            ],
            columns: [
                {
                    xtype: 'gridcolumn',
                    width: 83,
                    dataIndex: 'duedate',
                    text: 'Due Date',
                    renderer: function (value, metaData, record, rowIdx, colIdx , store, view) {
                        var val = Ext.util.Format.date(value),
                            overdue = record.get('dayspastdue') > 0;

                        if (overdue) {
                            return '<span style="color:red;">' + val + '</span>';
                        }
                        return val;
                    }
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'projectcode',
                    text: 'Project'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'title',
                    flex: 1,
                    text: 'Title'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'contact',
                    hidden: true,
                    text: 'Contact',

                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'email',
                    hidden: true,
                    text: 'E-mail',
                    renderer: function(value) {
                        return value ? '<a href="mailto:' + value + '">' + value + '</a>' : '';
                    }
                }
            ]
        });

        me.callParent(arguments);
    }
});
