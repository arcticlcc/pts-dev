/**
 * Grid for TPS Report.
 */

Ext.define('PTS.view.tps.tab.TpsGrid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.tpsgrid',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid',
        'PTS.util.Format',
        'Ext.ux.grid.HeaderToolTip'
    ],

    autoScroll: true,
    //title: 'Tasks',
    store: 'TpsRecords',
    selType: 'cellmodel',

    initComponent: function() {
        var me = this, sm,
            cols = [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'modtype',
                    text: 'Agreement Type',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'shorttitle',
                    text: 'Project',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'projectcode',
                    text: 'Project Code',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'title',
                    hidden: true,
                    text: 'Title',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'modificationcode',
                    hidden: true,
                    text: 'Agreement #',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'principalinv',
                    hidden: true,
                    text: 'PI Name',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'invemail',
                    hidden: true,
                    text: 'PI e-mail',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'recipient',
                    hidden: true,
                    text: 'Funding Recipient',
                    locked: true
                }
            ];

        Ext.applyIf(me, {
            viewConfig: {

            },
            dockedItems: [
                {
                    xtype: 'pagingtoolbar',
                    store: 'TpsRecords',   // same store GridPanel is using
                    dock: 'top',
                    displayInfo: true,
                    plugins: [
                        Ext.create('Ext.ux.grid.PrintGrid', {
                            title: function(){
                                return this.child('cycle#filter').getActiveItem().text + ' (TPS Report)';
                            }
                        })/*,
                        Ext.create('Ext.ux.grid.SaveGrid', {
                            hidden: true
                        })*/
                    ],
                    items: [
                        '-',
                        {
                            xtype: 'cycle',
                            itemId: 'filter',
                            showText: true,
                            action: 'filterrecords',
                            tooltip: 'Click to filter the Records',
                            menu: {
                                xtype: 'menu',
                                width: 120,
                                items: [
                                    {
                                        //xtype: 'menucheckitem',
                                        iconCls: 'pts-flag-red',
                                        text: 'Active',
                                        filter: 'active'
                                    },
                                    {
                                        //xtype: 'menucheckitem',
                                        iconCls: 'pts-flag-green',
                                        text: 'Funded',
                                        filter: 'funded'
                                    },
                                    {
                                        //xtype: 'menucheckitem',
                                        iconCls: 'pts-flag-white',
                                        text: 'All',
                                        filter: 'all'
                                    }
                                ]
                            }
                        }
                    ]
                }
            ],
            columns: cols
        });

        me.addEvents(
            /**
             * @event beforeselect
             * Fired before a record is selected. If any listener returns false, the
             * selection is cancelled.
             * @param {Ext.grid.View} The selected view
             * @param {Ext.data.Model} record The selected record
             * @param {Object} position The position of selected cell
             */
            'beforeselect'
        );

        me.callParent(arguments);

        sm = me.getSelectionModel();
        //Override onMouseDown to prevent clicks on the locked view
        sm.onMouseDown = function(view, cell, cellIndex, record, row, rowIndex, e) {
            if(sm.primaryView !== view) {return false;}
            sm.setCurrentPosition({
                row: rowIndex,
                column: cellIndex
            }, view);
        };

        //code below will "fix" the loadmask, i.e. masks entire panel
        //http://www.sencha.com/forum/showthread.php?188261-OPEN-Bugs-on-Grid-with-Column-Locking-load-mask-error-grid-not-resized-etc&p=784431&viewfull=1#post784431
        /*if(me.normalGrid && me.lockedGrid) {
            if(me.normalGrid.view.loadMask) {
                var $loc_LoadMask = new Ext.LoadMask(Ext.getBody(), {
                    ownerCt: me
                });
                me.normalGrid.view.loadMask = {
                    onBeforeLoad: function() {
                        $loc_LoadMask.show();
                    },
                    onLoad: function() {
                        $loc_LoadMask.hide();
                    }
                };
                me.lockedGrid.view.loadMask = false;
            }
        }*/
    }
});
