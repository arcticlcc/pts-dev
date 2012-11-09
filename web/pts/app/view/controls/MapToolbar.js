/**
 * Toolbar for use with GeoExt map panels.
 */
Ext.define('PTS.view.controls.MapToolbar', {
    extend: 'Ext.toolbar.Toolbar',
    alias: 'widget.maptoolbar',
    requires: [
        'GeoExt.Action',
        'PTS.view.button.Edit',
        'PTS.view.button.Save',
        'Ext.button.Button',
        'Ext.button.Split',
        'Ext.menu.CheckItem'
    ],

    /**
     * @cfg {OpenLayers.Map/GeoExt.MapPanel} map
     * The map that the toolbar controls.
     */
    map: null,

    /**
     * @cfg {OpenLayers.Layer.Vector} vectorLayer
     * The vector layer that edit actions operate on.
     */
    vectorLayer: null,

    /**
     * @cfg {OpenLayers.Strategy.Save} saveStrategy
     * The vector layer save strategy.
     */
    saveStrategy: null,

    initComponent: function() {
        var me = this,
            map = me.map,
            vector = me.vectorLayer,
            items = [],
            ctrl,
            modify,
            sel;

        //select on hover
        sel = new OpenLayers.Control.SelectFeature(vector,{
            id: 'PTS-Select-Hover',
            hover: true,
            highlightOnly: true,
            renderIntent: "temporary",
            //add beforefeatureunhighlighted event
            unhighlight: function(feature) {
                var layer = feature.layer,
                    cont = this.events.triggerEvent("beforefeatureunhighlighted", {
                        feature : feature
                    });

                if(cont !== false) {
                    // three cases:
                    // 1. there's no other highlighter, in that case _prev is undefined,
                    //    and we just need to undef _last
                    // 2. another control highlighted the feature after we did it, in
                    //    that case _last references this other control, and we just
                    //    need to undef _prev
                    // 3. another control highlighted the feature before we did it, in
                    //    that case _prev references this other control, and we need to
                    //    set _last to _prev and undef _prev
                    if(feature._prevHighlighter == undefined) {
                        delete feature._lastHighlighter;
                    } else if(feature._prevHighlighter == this.id) {
                        delete feature._prevHighlighter;
                    } else {
                        feature._lastHighlighter = feature._prevHighlighter;
                        delete feature._prevHighlighter;
                    }
                    layer.drawFeature(feature, feature.style || feature.layer.style ||
                        "default");
                    this.events.triggerEvent("featureunhighlighted", {feature : feature});
                }
            },
            outFeature: function(feature) {
                if(this.hover) {
                    if(this.highlightOnly) {
                        var cont = this.events.triggerEvent("beforefeatureunhighlighted", {
                                feature : feature
                            });
                        if(cont !== false) {
                            // we do nothing if we're not the last highlighter of the
                            // feature
                            if(feature._lastHighlighter == this.id) {
                                // if another select control had highlighted the feature before
                                // we did it ourself then we use that control to highlight the
                                // feature as it was before we highlighted it, else we just
                                // unhighlight it
                                if(feature._prevHighlighter &&
                                   feature._prevHighlighter != this.id) {
                                    delete feature._lastHighlighter;
                                    var control = this.map.getControl(
                                        feature._prevHighlighter);
                                    if(control) {
                                        control.highlight(feature);
                                    }
                                } else {
                                    this.unhighlight(feature);
                                }
                            }
                        }
                    } else {
                        this.unselect(feature);
                    }
                }
            }/*,
            eventListeners: {
                beforefeaturehighlighted: report,
                featurehighlighted: report,
                featureunhighlighted: report
            }*/
        });

        /*sel.events.on({
            "beforefeaturehighlighted": function(evt) {
                if(this.highlightOnly && evt.feature.renderIntent === "select") {
                    return false;
                }
            },
            "beforefeatureunhighlighted": function(evt) {
                if(this.highlightOnly && evt.feature.renderIntent === "select") {
                    return false;
                }
            }
        });*/


        // ZoomToMaxExtent control, a "button" control
        /*items.push(Ext.create('Ext.button.Button', Ext.create('GeoExt.Action', {
            control: new OpenLayers.Control.ZoomToMaxExtent(),
            map: map,
            text: "max extent",
            tooltip: "zoom to max extent"
        })));*/

        items.push("-");

        // Navigation control
        items.push(Ext.create('Ext.button.Button',{
            text: 'Pan',
            iconCls: 'pts-menu-pan',
            //control: new OpenLayers.Control.Navigation(),
            //map: map,
            // button options
            toggleGroup: "draw",
            allowDepress: false,
            pressed: true,
            tooltip: "Pan the map"//,
            // check item options
            //group: "draw",
            //checked: true
        }));

        items.push(Ext.create('Ext.button.Button',Ext.create('GeoExt.Action', {
            text: 'Draw Point',
            iconCls: 'pts-menu-point',
            control: new OpenLayers.Control.DrawFeature(vector, OpenLayers.Handler.Point),
            map: map,
            // button options
            toggleGroup: "draw",
            allowDepress: false,
            tooltip: "Draw a point"//,
            // check item options
            //group: "draw"
        })));

        items.push(Ext.create('Ext.button.Button',Ext.create('GeoExt.Action', {
            text: 'Draw Line',
            iconCls: 'pts-menu-line',
            control: new OpenLayers.Control.DrawFeature(vector, OpenLayers.Handler.Path),
            map: map,
            // button options
            toggleGroup: "draw",
            allowDepress: false,
            tooltip: "Draw a line"//,
            // check item options
            //group: "draw"
        })));

        items.push(Ext.create('Ext.button.Button',Ext.create('GeoExt.Action', {
            text: 'Draw Polygon',
            iconCls: 'pts-menu-polygon',
            control: new OpenLayers.Control.DrawFeature(vector, OpenLayers.Handler.Polygon),
            map: map,
            // button options
            toggleGroup: "draw",
            allowDepress: false,
            tooltip: "Draw a polygon"//,
            // check item options
            //group: "draw"
        })));

        /*items.push(Ext.create('Ext.button.Button',Ext.create('GeoExt.Action', {
            text: 'Modify',
            iconCls: 'pts-menu-modify',
            control: new OpenLayers.Control.ModifyFeature(vector),
            map: map,
            // button options
            toggleGroup: "draw",
            allowDepress: false,
            tooltip: "Modify a feature"//,
            // check item options
            //group: "draw"
        })));*/

        vector.styleMap.styles.vertex = new OpenLayers.Style({
                fillColor: "#EEEC00",
                fillOpacity: 0.4,
                hoverFillColor: "white",
                hoverFillOpacity: 0.8,
                strokeColor: "#EEEC00",
                strokeOpacity: 1,
                strokeWidth: 1,
                strokeLinecap: "round",
                strokeDashstyle: "solid",
                hoverStrokeColor: "red",
                hoverStrokeOpacity: 1,
                hoverStrokeWidth: 0.2,
                pointRadius: 6,
                hoverPointRadius: 1,
                hoverPointUnit: "%",
                pointerEvents: "visiblePainted",
                cursor: "inherit",
                fontColor: "#000000",
                labelAlign: "cm",
                labelOutlineColor: "white",
                labelOutlineWidth: 3
        });

        modify = new OpenLayers.Control.ModifyFeature(vector,{
            id:'PTS-Modify-Feature',
            vertexRenderIntent: 'vertex'
        });

        items.push(Ext.create('Ext.button.Split', Ext.create('GeoExt.Action', {
            text: 'Modify',
            itemId: 'modify',
            iconCls: 'pts-menu-modify',
            control: modify,
            map: map,
            toggleGroup: "draw",
            allowDepress: false,
            tooltip: "Modify a feature",
            menu: {
                items: [
                    {
                        xtype: 'menucheckitem',
                        text:'Modify',
                        iconCls: 'pts-menu-modify',
                        group: 'modoptions',
                        checked: true,
                        modoption: OpenLayers.Control.ModifyFeature.RESHAPE
                    },
                    {
                        xtype: 'menucheckitem',
                        text:'Move',
                        iconCls: 'pts-menu-move',
                        group: 'modoptions',
                        modoption: OpenLayers.Control.ModifyFeature.DRAG
                    },
                    {
                        xtype: 'menucheckitem',
                        text:'Resize',
                        iconCls: 'pts-menu-resize',
                        group: 'modoptions',
                        modoption: OpenLayers.Control.ModifyFeature.RESIZE
                    },
                    {
                        xtype: 'menucheckitem',
                        text:'Rotate',
                        iconCls: 'pts-menu-rotate',
                        group: 'modoptions',
                        modoption: OpenLayers.Control.ModifyFeature.ROTATE
                    }
                ]
            },
            listeners: {
                render: function(btn){
                    btn.menu.items.each(function(itm) {
                        itm.on('checkchange', function(chkItm, checked) {
                            var feature = modify.feature;

                            if(checked) {
                                modify.mode = chkItm.modoption;
                                //set the correct icon and text
                                btn.setText(chkItm.text);
                                btn.setIconCls(chkItm.iconCls);

                                if(feature) {
                                    //we need to reselect the feature to update the control
                                    modify.unselectFeature(feature);
                                    modify.selectFeature(feature);
                                }
                                //make sure the button is pressed
                                btn.toggle(true);
                            }
                        });
                    });
                }/*,
                toggle: function(btn, pressed){
                    console.info(btn);
                    console.info(sel);
                    sel.highlightOnly = pressed;
                }*/
            }
        })));

        items.push("-");

        items.push({
            xtype: 'savebutton',
            handler: function() {
                me.saveStrategy.save();
            },
            disabled: false
        });

        items.push("-");

        // Navigation history - two "button" controls
        ctrl = new OpenLayers.Control.NavigationHistory();
        map.addControl(ctrl);

        items.push(Ext.create('Ext.button.Button', Ext.create('GeoExt.Action', {
            //text: "previous",
            iconCls: "pts-arrow-left",
            control: ctrl.previous,
            disabled: true,
            tooltip: "previous in history"
        })));

        items.push(Ext.create('Ext.button.Button', {
            //text: "next",
            iconCls: "pts-arrow-right",
            control: ctrl.next,
            disabled: true,
            tooltip: "next in history"
        }));
        items.push("->");

        // Help action
        items.push(
            Ext.create('Ext.button.Button', {text: 'Help'})
        );

        Ext.apply(me, {

                dock: 'top',
                items: items//,
                /*style: {
                    border: 0,
                    padding: 0
                }*/
        });
        me.callParent(arguments);
    }
});
