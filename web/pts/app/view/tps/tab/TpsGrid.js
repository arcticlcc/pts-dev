/**
 * Grid for TPS Report.
 */

Ext.define('PTS.view.tps.tab.TpsGrid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.tpsgrid',
    requires: [
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid',
        'PTS.util.Format'        
    ],

    autoScroll: true,
    //title: 'Tasks',
    store: 'TpsRecords',

    initComponent: function() {
        var me = this,
            cols = [
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'modtype',
                    flex: 1,
                    text: 'Agreement Type',
                    locked: true
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'shorttitle',
                    flex: 1,
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
                            action: 'filterrecords',
                            tooltip: 'Click to filter the Records',
                            menu: {
                                xtype: 'menu',
                                width: 120,
                                items: [
                                    {
                                        //xtype: 'menucheckitem',
                                        iconCls: 'pts-menu-users',
                                        text: 'Show Active',
                                        filter: 'active'
                                    },
                                    {
                                        //xtype: 'menucheckitem',
                                        iconCls: 'pts-menu-user',
                                        text: 'Show Submitted',
                                        filter: 'submit'
                                    },
                                    {
                                        //xtype: 'menucheckitem',
                                        iconCls: 'pts-menu-exclamation',
                                        text: 'Show all',
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

        me.callParent(arguments);
        
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
