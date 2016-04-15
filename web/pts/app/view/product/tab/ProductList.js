/**
 * File: app/view/product/ProductList.js
 * Description: List of products.
 */

Ext.define('PTS.view.product.tab.ProductList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.productlist',
    requires: [
        //'PTS.util.Format',
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid',
        'Ext.ux.grid.FilterBar',
        'Ext.ux.grid.PagingToolbarResizer'
    ],

    store: 'Products',
    title: 'Product List',
    preventHeader: true,

    initComponent: function() {
        var me = this;
        var groupingFeature = Ext.create('Ext.grid.feature.Grouping', {
            groupHeaderTpl: 'Group: {name} ({rows.length})', //print the number of items in the group
            startCollapsed: true // start all groups collapsed
        });

        Ext.applyIf(me, {
            features: [groupingFeature],
            dockedItems: [{
                xtype: 'pagingtoolbar',
                store: 'Products',
                displayInfo: true,
                plugins: [
                    Ext.create('Ext.ux.grid.PrintGrid', {}),
                    Ext.create('Ext.ux.grid.SaveGrid', {}),
                    Ext.create('Ext.ux.grid.PagingToolbarResizer', {
                        options: [25, 50, 100, 200, 500]
                    })
                ]
            }],
            columns: [{
                    xtype: 'actioncolumn',
                    width: 25,
                    items: [{
                        iconCls: 'pts-world-link',
                        tooltip: 'Open Website',
                        handler: function(grid, rowIndex, colIndex) {
                            var rec = grid.getStore().getAt(rowIndex),
                                fy = rec.get('fiscalyear'),
                                num = rec.get('number'),
                                url = PTS.user.get('producturiformat').replace(/(%s)/, fy).replace(/(%s)/, num < 10 ? '0' + num : num);

                            window.open(url);
                        }
                    }]
                }, {
                    xtype: 'gridcolumn',
                    dataIndex: 'projectcode',
                    text: 'Project'
                }, {
                    xtype: 'gridcolumn',
                    //width: 221,
                    dataIndex: 'title',
                    text: 'Title',
                    flex: 1
                }, {
                    xtype: 'gridcolumn',
                    hidden: true,
                    dataIndex: 'description',
                    text: 'Description',
                    flex: 1
                },
                /*{
                    xtype: 'gridcolumn',
                    dataIndex: 'status',
                    text: 'Status',
                    width: 80
                },*/
                {
                    xtype: 'gridcolumn',
                    text: 'Type',
                    dataIndex: 'type'
                        //width: 55
                }, {
                    xtype: 'gridcolumn',
                    hidden: false,
                    dataIndex: 'productgroup',
                    text: 'Group',
                    flex: 1
                }, {
                    xtype: 'booleancolumn',
                    text: 'Export',
                    trueText: 'Yes',
                    falseText: 'No',
                    dataIndex: 'exportmetadata',
                    //hidden: true,
                    width: 55
                }, {
                    xtype: 'booleancolumn',
                    text: 'Is Group',
                    trueText: 'Yes',
                    falseText: 'No',
                    dataIndex: 'isgroup',
                    //hidden: true,
                    width: 55
                }, {
                    text: 'Time Period',
                    hidden: true,
                    columns: [{
                        xtype: 'datecolumn',
                        dataIndex: 'startdate',
                        text: 'Begin',
                        hidden: true,
                        width: 75,
                        sortable: true
                    }, {
                        xtype: 'datecolumn',
                        dataIndex: 'enddate',
                        text: 'End',
                        hidden: true,
                        width: 75,
                        sortable: true
                    }]
                }
            ]
        });

        me.callParent(arguments);

        me.addDocked({
            xtype: 'filterbar',
            searchStore: me.store,
            dock: 'bottom'
        });
    }
});
