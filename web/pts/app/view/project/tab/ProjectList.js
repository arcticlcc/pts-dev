/**
 * File: app/view/project/ProjectList.js
 * Description: List of projects.
 */

Ext.define('PTS.view.project.tab.ProjectList', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.projectlist',
    requires: [
        'PTS.util.Format',
        'Ext.ux.grid.PrintGrid',
        'Ext.ux.grid.SaveGrid',
        'Ext.ux.grid.FilterBar'
    ],

    store: 'ProjectListings',
    title: 'Project List',
    preventHeader: true,
    /*viewConfig: {
        listeners: {
            itemcontextmenu: function(view, rec, el, index, e){
                // Stop the browser getting the event
                e.preventDefault();
                //console.info(rec);
                id = rec.get('id');
                this.getSelectionModel().select(index);
                var menu = new ArcticPTS.view.Util().contextMenu(id);
                menu.showAt(e.getXY());
                return false;
            }
        }
    },
    listeners: {
        select: {
            fn: function(rm, record, index,opts){
                var id = record.get('id');
                var tab = Ext.getCmp('alcc-projectdetails-tp').getActiveTab();
                //console.info(index);
                //console.info(tab.selectedProject+','+index);
                if(tab.selectedProject !== index) { //check to see if project has changed
                    if(typeof tab.getStore === 'function') { //test for getStore method
                        var store = tab.getStore();
                        store.clearFilter();
                        store.filter('projectid',Ext.Number.from(id,0));
                        if(tab.isXType('treepanel')) {
                            store.getRootNode().removeAll();
                        }
                        store.load();
                        tab.selectedProject = index;
                    }
                }
                Ext.getCmp('alcc-project-calendar').store.getProxy().extraParams = {
                    projectid: id
                };
                Ext.getCmp('alcc-project-calendar').getActiveView().reloadStore({ //filter calendar
                    params: {
                        projectid: id
                }});

                //update map
                var layer, v, g, map, ext, mapPanel;

                map = Ext.getCmp('alcc-projectmap').map;
                layer = map.getLayersByName('Project')[0];
                layer.removeAllFeatures();
                v = record.get('bounds');
                //console.info(v);
                g =  new OpenLayers.Format.WKT();
                layer.addFeatures([g.read(v)]);
                ext = layer.getDataExtent();
                //console.info(map.getZoomForExtent(ext));
                if(map.getZoomForExtent(ext) <= 12) {
                    map.zoomToExtent(layer.getDataExtent());
                } else {
                    map.setCenter(ext.getCenterLonLat(), 12);
                }
                mapPanel = Ext.getCmp('alcc-projectmap');
                mapPanel.mapState = mapPanel.getState();
            }
        },
        viewready : function(grid) {
            var store = grid.getStore();
            grid.getSelectionModel().select(0);
            //console.info(grid);
            if (store) {
                store.on('load', function(){this.getSelectionModel().select(0);},grid);
            }
        }
    },*/

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            dockedItems: [{
                xtype: 'pagingtoolbar',
                store: 'ProjectListings',
                displayInfo: true,
                plugins: [
                    Ext.create('Ext.ux.grid.PrintGrid', {}),
                    Ext.create('Ext.ux.grid.SaveGrid', {})
                ]
            }],
            columns: [
                {
                    xtype:'actioncolumn',
                    width:25,
                    items: [{
                        iconCls: 'pts-world-link',
                        tooltip: 'Open Website',
                        handler: function(grid, rowIndex, colIndex) {
                            var val = grid.getStore().getAt(rowIndex).get('projectcode');
                            window.open('http://arcticlcc.org/projects/'+val);
                        }
                    }]
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'projectcode',
                    text: 'Project'
                },
                {
                    xtype: 'gridcolumn',
                    //width: 221,
                    dataIndex: 'title',
                    text: 'Title',
                    flex: 1
                },
                {
                    xtype: 'gridcolumn',
                    hidden: true,
                    dataIndex: 'shorttitle',
                    text: 'Short Title',
                    flex: 1
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'status',
                    text: 'Status',
                    width: 80
                },
                {
                    xtype: 'booleancolumn',
                    text: 'Export',
                    trueText: 'Yes',
                    falseText: 'No',
                    dataIndex: 'exportmetadata',
                    hidden: true,
                    width: 55
                },
                {
                    text: 'Funding',
                    columns: [
                        {
                            //xtype: 'gridcolumn',
                            dataIndex: 'allocated',
                            text: 'Allocated',
                            width : 75,
                            sortable : true,
                            renderer: Ext.util.Format.usMoney
                        },
                        {
                            //xtype: 'gridcolumn',
                            dataIndex: 'invoiced',
                            text: 'Invoiced',
                            width : 75,
                            sortable : true,
                            renderer: Ext.util.Format.usMoney
                        },
                        {
                            //xtype: 'gridcolumn',
                            dataIndex: 'difference',
                            text: 'Difference',
                            width : 75,
                            sortable : true,
                            renderer: PTS.util.Format.netFunds
                        },
                        {
                            //xtype: 'gridcolumn',
                            dataIndex: 'leveraged',
                            text: 'Leveraged',
                            width : 75,
                            sortable : true,
                            hidden: true,
                            renderer: Ext.util.Format.usMoney
                        }
                    ]
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
