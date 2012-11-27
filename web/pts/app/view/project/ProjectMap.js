/**
 * Project map with optional toolbar.
 */

Ext.define('PTS.view.project.ProjectMap', {
    extend: 'GeoExt.panel.Map',
    alias: 'widget.projectmap',
    requires: [
        'GeoExt.panel.Map',
        'GeoExt.slider.Zoom',
        'GeoExt.slider.Tip',
        'GeoExt.slider.LayerOpacity',
        'Ext.toolbar.Toolbar',
        'PTS.view.controls.MapToolbar',
        'PTS.view.button.Edit',
        'PTS.view.button.Save'
    ],

    title: 'Map',

    /**
     * @cfg {boolean} showTools
     * True to show the map toolbar.
     */
    displayTools: true,

    /**
     * @cfg {OpenLayers.Layer.Vector} projectVectors
     * The vector layer containing project features.
     */

    /**
     * @cfg {Ext.toolbar.Toolbar} mapToolbar
     * The map toolbar.
     */
    mapToolbar: undefined,

    initComponent: function() {
        var me = this,
            wms = new OpenLayers.Layer.WMS(
                "OpenLayers WMS",
                "http://vmap0.tiles.osgeo.org/wms/vmap0?",
                {layers: 'basic'}
            ),
            bdl = new OpenLayers.Layer.TMS("SDMI BDL(Alaska Albers)", "http://swmha.gina.alaska.edu/tilesrv/bdl/tile/",{
                    type: 'jpeg',
                    wrapDateLine: true,
                    isBaseLayer: true,
                    getURL:function(bounds) {
                        var res = this.map.getResolution();
                        var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
                        var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
                        var z = this.map.getZoom();
                        var tileCount = (1 << z);

                        //Wrap the X value
                        var X = (x % tileCount);
                        //Check for JS modulo operator possibly returning negative values
                        if(X < 0) { X += tileCount; }

                        var path = X + "/" + y + "/" + z;
                        var url = this.url;
                        if (url instanceof Array) {
                            url = this.selectUrl(path, url);
                        }
                        return url + path;
                }}),
            saveStrategy = new OpenLayers.Strategy.Save(),
            fixedStrategy = new OpenLayers.Strategy.Fixed(),
            refreshStrategy = new OpenLayers.Strategy.Refresh(),
            vector = new OpenLayers.Layer.Vector("Project Features",{
                visibility: false,
                strategies: [
                    refreshStrategy,
                    fixedStrategy,
                    saveStrategy
                ],
                protocol: new OpenLayers.Protocol.HTTP({
                    url: '../projectfeature',
                    format: new OpenLayers.Format.GeoJSON({
                        ignoreExtraDims: true
                    }),
                    deleteWithPOST: true
                })
            }),
            protoCallBack = function(resp) {
                //console.info(arguments);
                if(resp.code !== OpenLayers.Protocol.Response.SUCCESS) {
                    PTS.app.showError('There was an error processing the features.</br>Error: ' + Ext.decode(resp.priv.responseText).message);
                } else if(resp.requestType.toLowerCase() !== 'delete'){
                //custom event called when successful
                    this.projectVectors.events.triggerEvent("ptsfeaturesupdated", resp);
                }
            };

        //TODO: better error handling, specific to type of operation
        vector.protocol.options.update = { callback: protoCallBack, scope: this };
        vector.protocol.options.create = { callback: protoCallBack, scope: this };
        vector.protocol.options.delete = { callback: protoCallBack, scope: this };

        var layerInfo = {
          "currentVersion" : 10.01,
          "mapName" : "Layers",
          "copyrightText" : "Sources: Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, USGS, FAO, NPS, NRCAN, GeoBase, IGN, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), and the GIS User Community",
          "spatialReference" : {
            "wkid" : 102100
          },
          "singleFusedMapCache" : true,
          "tileInfo" : {
            "rows" : 256,
            "cols" : 256,
            "dpi" : 96,
            "format" : "JPEG",
            "compressionQuality" : 90,
            "origin" : {
              "x" : -20037508.342787,
              "y" : 20037508.342787
            },
            "spatialReference" : {
              "wkid" : 102100
            },
            "lods" : [
              {"level" : 0, "resolution" : 156543.033928, "scale" : 591657527.591555},
              {"level" : 1, "resolution" : 78271.5169639999, "scale" : 295828763.795777},
              {"level" : 2, "resolution" : 39135.7584820001, "scale" : 147914381.897889},
              {"level" : 3, "resolution" : 19567.8792409999, "scale" : 73957190.948944},
              {"level" : 4, "resolution" : 9783.93962049996, "scale" : 36978595.474472},
              {"level" : 5, "resolution" : 4891.96981024998, "scale" : 18489297.737236},
              {"level" : 6, "resolution" : 2445.98490512499, "scale" : 9244648.868618},
              {"level" : 7, "resolution" : 1222.99245256249, "scale" : 4622324.434309},
              {"level" : 8, "resolution" : 611.49622628138, "scale" : 2311162.217155},
              {"level" : 9, "resolution" : 305.748113140558, "scale" : 1155581.108577},
              {"level" : 10, "resolution" : 152.874056570411, "scale" : 577790.554289},
              {"level" : 11, "resolution" : 76.4370282850732, "scale" : 288895.277144},
              {"level" : 12, "resolution" : 38.2185141425366, "scale" : 144447.638572},
              {"level" : 13, "resolution" : 19.1092570712683, "scale" : 72223.819286},
              {"level" : 14, "resolution" : 9.55462853563415, "scale" : 36111.909643},
              {"level" : 15, "resolution" : 4.77731426794937, "scale" : 18055.954822},
              {"level" : 16, "resolution" : 2.38865713397468, "scale" : 9027.977411},
              {"level" : 17, "resolution" : 1.19432856685505, "scale" : 4513.988705},
              {"level" : 18, "resolution" : 0.597164283559817, "scale" : 2256.994353},
              {"level" : 19, "resolution" : 0.298582141647617, "scale" : 1128.497176}
            ]
          },
          "initialExtent" : {
            "xmin" : -20037507.0671618,
            "ymin" : -19971868.8804086,
            "xmax" : 20037507.0671618,
            "ymax" : 19971868.8804086,
            "spatialReference" : {
              "wkid" : 102100
            }
          },
          "fullExtent" : {
            "xmin" : -20037507.0671618,
            "ymin" : -19971868.8804086,
            "xmax" : 20037507.0671618,
            "ymax" : 19971868.8804086,
            "spatialReference" : {
              "wkid" : 102100
            }
          },
          "units" : "esriMeters"
        };
        //The max extent for spherical mercator
        var maxExtent = new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34);
        //Max extent from layerInfo above
        var layerMaxExtent = new OpenLayers.Bounds(
            layerInfo.fullExtent.xmin,
            layerInfo.fullExtent.ymin,
            layerInfo.fullExtent.xmax,
            layerInfo.fullExtent.ymax
        );

        var resolutions = [];
        for (var i=0; i<layerInfo.tileInfo.lods.length; i++) {
            resolutions.push(layerInfo.tileInfo.lods[i].resolution);
        }
        var topo = new OpenLayers.Layer.ArcGISCache( "Topo",
            "http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer", {
                isBaseLayer: false,
                wrapDateLine: false,
                visibility: true,
                displayInLayerSwitcher:false,
                //From layerInfo above
                resolutions: resolutions,
                tileSize: new OpenLayers.Size(layerInfo.tileInfo.cols, layerInfo.tileInfo.rows),
                tileOrigin: new OpenLayers.LonLat(layerInfo.tileInfo.origin.x , layerInfo.tileInfo.origin.y),
                maxExtent: layerMaxExtent,
                projection: 'EPSG:' + layerInfo.spatialReference.wkid
            });
        var nmap = new OpenLayers.Layer.ArcGISCache( "National Map Vector",
            "http://basemap.nationalmap.gov/ArcGIS/rest/services/TNM_Vector_Small/MapServer", {
                isBaseLayer: false,
                wrapDateLine: false,
                visibility: false,
                //From layerInfo above
                resolutions: resolutions,
                tileSize: new OpenLayers.Size(layerInfo.tileInfo.cols, layerInfo.tileInfo.rows),
                tileOrigin: new OpenLayers.LonLat(layerInfo.tileInfo.origin.x , layerInfo.tileInfo.origin.y),
                //maxExtent: layerMaxExtent,
                projection: 'EPSG:' + layerInfo.spatialReference.wkid
            });
        var bdlMerc = new OpenLayers.Layer.XYZ( "GINA BDL",
                    "http://tiles.gina.alaska.edu/tilesrv/bdl/tile/${x}/${y}/${z}",
                    {sphericalMercator: true,isBaseLayer: false,wrapDateLine: true, displayInLayerSwitcher:false});

        var topoSlider = Ext.create('GeoExt.slider.LayerOpacity', {
            id: "topoSlider",
            layer: topo,
            complementaryLayer: bdlMerc,
            changeVisibility: true,
            aggressive: true,
            vertical: true,
            height: 120,
            x: 10,
            y: 200,
            plugins: Ext.create("GeoExt.slider.Tip", {
                getText: function(thumb) {
                    return Ext.String.format('{0}%', thumb.value);
                }
            })
        });

        var topoBdl = new OpenLayers.Layer( "Topo/Imagery",
                    {sphericalMercator: true,isBaseLayer: false,wrapDateLine: true, displayInLayerSwitcher:true});

        topoBdl.events.on({
            "visibilitychanged": function(evt) {
//console.info(arguments);
//console.info(this);
                var vis = evt.object.visibility,
                    slider = this;

                slider.setVisible(vis);
                slider.complementaryLayer.setVisibility(vis);
                slider.layer.setVisibility(vis);
            },
            scope: topoSlider
        });

        var plain = new OpenLayers.Layer( "Empty",
                    {sphericalMercator: true,isBaseLayer: true,wrapDateLine: true, displayInLayerSwitcher:false});

        me.map = new OpenLayers.Map('map', {
            maxExtent: maxExtent,
            //StartBounds: layerMaxExtent,
            units: (layerInfo.units == "esriFeet") ? 'ft' : 'm',
            resolutions: resolutions,
            tileSize: new OpenLayers.Size(layerInfo.tileInfo.cols, layerInfo.tileInfo.rows),
            projection: 'EPSG:' + layerInfo.spatialReference.wkid,
            layers: [plain,topoBdl,bdlMerc,topo,nmap,vector]
        });

        //prevent selection of feature with state === 'Deleted'
        vector.events.on({
            "beforefeatureselected": function(evt) {
                if(evt.feature.state === OpenLayers.State.DELETE) {
                    return false;
                }
            }
        });

        Ext.applyIf(me, {
//            center: '12.3046875,51.48193359375',
//            zoom: 6,
//            stateful: true,
//            stateId: 'mappanel',
//            extent: '12.87,52.35,13.96,52.66',
            items: [{
                xtype: "gx_zoomslider",
                vertical: true,
                height: 100,
                x: 10,
                y: 70,
                plugins: Ext.create('GeoExt.SliderTip', {
                    getText: function(thumb) {
                        var slider = thumb.slider,
                         out = '<div>Zoom Level: {0}</div>' +
                        '<div>Resolution: {1}</div>' +
                        '<div>Scale: 1 : {2}</div>';
                        return Ext.String.format(out, slider.getZoom(), slider.getResolution(), slider.getScale());
                    }
                })
            },
                topoSlider
            ],
            projectVectors: vector/*,
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                    text: 'Current center of the map',
                    handler: function(){
                        var c = GeoExt.panel.Map.guess().map.getCenter();
                        Ext.Msg.alert(this.getText(), c.toString());
                    }
                }]
            }]*/
        });

        me.callParent(arguments);

        me.map.addControl(new OpenLayers.Control.LayerSwitcher());
        //bind vector to store
        //Ext.getStore('ProjectVectors').bind(vector);

        if(me.displayTools) {
           me.mapToolbar =  {
                xtype: 'maptoolbar',
                map: me.map,
                vectorLayer: vector,
                saveStrategy: saveStrategy,
                refreshStrategy: refreshStrategy,
                maskCmp: true,
                dock: 'top',
                defaults: {
                    //disabled: true,
                    //hidden: true
                }/*,
                items: [
                    {
                        text: 'Current center of the map',
                        handler: function(){
                            var c = GeoExt.panel.Map.guess().map.getCenter();
                            Ext.Msg.alert(this.getText(), c.toString());
                        },
                        hidden: true
                    },{
                        xtype: 'editbutton',
                        disabled: false,
                        hidden: false,
                        handler: function(btn) {
                            btn.ownerCt.items.each(function(i) {
                                i.show();
                            });
                            btn.hide();
                        }
                    },{
                        xtype: 'savebutton'
                    }, Ext.create('Ext.button.Button', Ext.create('GeoExt.Action', {
                        control: new OpenLayers.Control.ZoomToMaxExtent(),
                        map: me.map,
                        text: "max extent",
                        tooltip: "zoom to max extent"
                    })),{
                        text: 'Draw Point',
                        iconCls: 'pts-menu-point',
                        action: 'addpoint'
                    },{
                        text: 'Draw Line',
                        iconCls: 'pts-menu-line',
                        action: 'addline'
                    },{
                        text: 'Draw Polygon',
                        iconCls: 'pts-menu-polygon',
                        action: 'addpolygon'
                    },{
                        text: 'Modify',
                        iconCls: 'pts-menu-modify',
                        action: 'modify'
                    }
                ]*/
            };
            me.addDocked(me.mapToolbar);
        }
    }
});
