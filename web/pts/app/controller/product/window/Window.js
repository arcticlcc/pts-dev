/**
 * Controller for Product Window
 */
Ext.define('PTS.controller.product.window.Window', {
    extend: 'Ext.app.Controller',

    views: [
        'product.window.Window',
        'product.form.ProductForm'
    ],
    stores: [
        'OnlineResources',
        'OnlineFunctions'//,
        /*'ProductComments',
        'ProductVectors',
        'CommonVectors'*/
    ],
    refs: [{
        ref: 'productWindow',
        selector: 'productwindow'
    },{
        ref: 'productForm',
        selector: 'productwindow productform'
    }/*,{
        ref: 'productMap',
        selector: 'productwindow productmap'
    },{
        ref: 'featureGrid',
        selector: 'productwindow #featureGrid'
    }*/],

    init: function() {

        var pf = this.getController('product.form.ProductForm')//,
            /*pc = this.getController('product.window.ProductContacts'),
            pm = this.getController('product.window.ProductMetadata'),
            pa = this.getController('product.window.ProductAgreements'),
            pk = this.getController('product.window.ProductKeywords')*/;
        // Remember to call the init method manually
        pf.init();
        /*pc.init();
        pa.init();
        pk.init();
        pm.init();*/

        this.control({
            'productwindow [action=closewindow]': {
                click: this.closeWindow
            },
            'productwindow': {
                beforeclose: this.onBeforeClose
            },
            'productwindow gridform': {
                loadrecord: this.onGridFormLoadRecord
            }/*,
            'productwindow>tabpanel>commenteditgrid': {
                edit: this.onCommentRowEdit
            },
            'productwindow productmap': {
                beforerender: this.onProductMapBeforeRender,
                afterlayout: this.onProductMapAfterLayout
            },
            'productwindow productmap maptoolbar': {
                beforerender: this.onMapToolbarBeforeRender
            },
            'productwindow productmap maptoolbar #addFeature menuitem': {
                click: this.onAddFeatureMenuClick
            },
            'productwindow productmap maptoolbar button#modify': {
                toggle: this.onModifyBtnToggle
            },
            'productwindow #featureGrid gridview': {
                viewready: this.onFeatureGridReady
            },
            'productwindow #featureGrid': {
                deselect: this.onFeatureGridDeselect
            }*/
        });
    },

    /**
     * Closes the product window.
     */
    closeWindow: function() {
        this.getProductWindow().close();
    },

    /**
     * The product window close event.
     */
    onBeforeClose: function() {
        //unbind the ProductVectors store
        //this.getProductVectorsStore().unbind();

        this.application.fireEvent('closeproduct');
    },

    /**
     * Update the record in the gridform with the productid.
     */
    onGridFormLoadRecord: function(rec) {
        var id = this.getProductWindow().productId;

        if(!rec.get('productid')){
            rec.set('productid', id);
        }
    },

    /**
     * Update the record in the commenteditgrid store with the productid.
     */
    onCommentRowEdit: function(editor, e) {
        var model = this.getProductForm().getRecord(),
            id = model.getId();

        editor.record.set('productid',id);
        editor.store.sync();
    },

    /**
     * MapToolbar beforerender handler
     */
    onMapToolbarBeforeRender: function(tb) {
        tb.maskCmp = this.getProductMap().ownerCt;
    },

    /**
     * On click handler for the addFeature menu
     */
    onAddFeatureMenuClick: function(item, evt) {
        var rec = this.getCommonVectorsStore().getById(item.itemId),
            wkt = rec.get('wkt');

        if(wkt) {
            this.getProductMap().addVector(wkt);
        }
    },

    /**
     * ProductMap afterlayout handler
     */
    onProductMapAfterLayout: function(mapPanel) {

        //add productid param to productVectors protocol
        mapPanel.productVectors.protocol.options.params = {
            productid: this.getProductWindow().productId
        };

        //listeners for product vector layer
        mapPanel.productVectors.events.on({
            "beforedeletetoggle": function(evt) {
                if(evt.feature.state !== OpenLayers.State.DELETE) {
                    this.getSelectionModel().deselect(this.getStore().getByFeature(evt.feature),true);
                }
            },
            "deletetoggle": function(evt) {
                var rec = this.getStore().getByFeature(evt.feature),
                    row = this.getView().getNode(rec),
                    rowEl = Ext.get(row);

                if(evt.feature.state === OpenLayers.State.DELETE) {
                    if(rowEl) {rowEl.addCls('pts-delete-highlight');}
                } else {
                    if(rowEl) {rowEl.removeCls('pts-delete-highlight');}
                }
            },
            "loadstart": function(evt) {
                mapPanel.ownerCt.getEl().mask('Loading product features...');
            },
            "loadend": function(evt) {
                var resp = evt.response,
                    bnd, map, zoom;

                if(resp.code !== OpenLayers.Protocol.Response.SUCCESS) {
                    PTS.app.showError('There was an error loading the features.</br>Error: ' + Ext.decode(resp.priv.responseText).message);
                }

                if(mapPanel.zoomOnLoad && evt.object.features.length) {
                    bnd = evt.object.getDataExtent();
                    map = mapPanel.map;
                    zoom = map.getZoomForExtent(bnd);

                    if(zoom <= mapPanel.maxZoomOnLoad) {
                        map.zoomToExtent(bnd);
                    } else {
                        map.setCenter(bnd.getCenterLonLat(),
                            mapPanel.maxZoomOnLoad,
                            false, false);
                    }
                }
                mapPanel.zoomOnLoad = false;
                mapPanel.ownerCt.getEl().unmask();
            },
            "refresh": function(evt) {
                //deselect feature row before refresh to prevent grid selection events
                //from trying to access non-existent objects after refresh
                this.getSelectionModel().deselectAll();
            },
            "ptsfeaturesupdated": function(resp) {
                var store = this.getStore(),
                    type = resp.requestType.toLowerCase(),
                    features;

                //update the state of the grid records
                if(type === 'create') {
                    features = resp.reqFeatures;
                    //create does not return an array for single record
                    if(Ext.typeOf(features) !== 'array') {
                        features = [features];
                    }
                    Ext.each(features, function(f) {
                        store.getById(f.id).commit();
                    });
                } else {
                    features = resp.features;
                    Ext.each(features, function(f) {
                        store.data.findBy(function(record) {
                            return record.raw.fid === f.fid;
                        }).commit();
                    });
                }
            },
            scope: this.getFeatureGrid()
        });

        //load productvectors
        mapPanel.productVectors.setVisibility(true);
    },

    /**
     * ProductMap beforerender handler
     */
    onProductMapBeforeRender: function(mapPanel) {
        var ctl,
            grid = this.getFeatureGrid();

        //select on hover, proper way to do this would be to extend
        //the SelectFeature control
        ctl = new OpenLayers.Control.SelectFeature(mapPanel.productVectors,{
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
            //highlight gridrow
            overFeature: function(feature,noHilite) {
                var layer = feature.layer;

                if(this.hover) {
                    if(this.highlightOnly) {
                        this.highlight(feature);
                    } else if(OpenLayers.Util.indexOf(
                        layer.selectedFeatures, feature) == -1) {
                        this.select(feature);
                    }
                }

                if(!noHilite) {
                    var rec = grid.getStore().getByFeature(feature),
                        row = grid.getView().getNode(rec),
                        rowEl = Ext.get(row);

                    if(rowEl) {rowEl.addCls('pts-vector-highlight');}
                }
            },
            //remove row highlight ad beforeunhighlight event
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

                    var rec = grid.getStore().getByFeature(feature),
                        row = grid.getView().getNode(rec),
                        rowEl = Ext.get(row);

                    if(rowEl) {rowEl.removeCls('pts-vector-highlight');}
                }
            }
        });

        ctl.events.on({
            "beforefeatureunhighlighted": function(evt) {
                var mod = ctl.map.getControlsBy('id','PTS-Modify-Feature')[0].feature;
                //redraw the feature with appropriate style if it's being modified
                if (ctl.highlightOnly && evt.feature === mod) {
                    ctl.layer.drawFeature(evt.feature, "select");
                    return false;
                }
            },
            "beforefeaturehighlighted": function(evt) {
                //don't do anything if this is a vertex
                if(evt.feature.renderIntent === 'vertex') {
                    var mod = ctl.map.getControlsBy('id','PTS-Modify-Feature')[0].feature;
                    //just redraw the feature if it's being modified
                    if(ctl.highlightOnly && evt.feature === mod) {
                        ctl.layer.drawFeature(evt.feature, "temporary");
                        return false;
                    }
                return false;
                }
            },
            scope: this
        });

        mapPanel.map.addControl(ctl);

        ctl.activate();

        this.getProductVectorsStore().bind(mapPanel.productVectors);
    },

    /**
     * MapToolbar Modify button toggle handler
     *
     * Use the ModifyFeature control to select vector tied
     * to currently selected grid row, if any.
     */
    onModifyBtnToggle: function(btn, pressed) {
        var map,
            sel = this.getFeatureGrid().getSelectionModel().selected;

        if(pressed && sel.length === 1) {
            map = btn.up('productmap').map;
            map.getControlsBy('id','PTS-Modify-Feature')[0].selectControl.select(sel.first().raw);
        }
    },

    /**
     * FeatureGrid viewready handler
     *
     * If the modifyfeature control is active, we call it's
     * selectFeature method when a grid row is selected.
     */
    onFeatureGridReady: function(view) {
        var ctl,
            addId,
            sel  = view.getSelectionModel().selectControl,
            hover = this.getProductMap().map.getControlsBy('id','PTS-Select-Hover')[0],
            store = view.getStore(),
            edit = view.ownerCt.getPlugin('cellEdit');

        sel.onSelect = function(feature) {
            ctl = this.map.getControlsBy('id','PTS-Modify-Feature')[0];

            if(ctl.active) {
                ctl.selectFeature(feature);
            }
        };

        //add the productid to new records
        addId = function(store, records) {
                Ext.each(records, function(r) {
                    r.beginEdit();
                    r.set('productid',view.up('productwindow').productId);
                    r.endEdit();
                });
            };

        //register listeners to update records
        store.on({
            add: addId,
            load: addId
        });
        //don't allow editing or selecting records marked for deletion
        edit.on({
            beforeedit: function(e) {
                if(e.record.raw.state === OpenLayers.State.DELETE) {
                    return false;
                }
            }
        });

        view.ownerCt.on({
            beforeselect: function(grid, rec) {
                if(rec.raw.state === OpenLayers.State.DELETE) {
                    return false;
                }
            }
        });

        view.on({
            //view listeners to higlight features on mouse over/out
            itemmouseenter: function(view, rec) {
                if(view.ownerCt.getPlugin('cellEdit').activeRecord !== rec) {
                    var ctl = rec.raw.layer.map.getControlsBy('id','PTS-Select-Hover')[0];
                    ctl.overFeature(rec.raw, true);
                }
            },
            itemmouseleave: function(view, rec) {
                var ctl,
                    layer = rec.raw.layer,
                    map = layer.map;

                if(view.ownerCt.getPlugin('cellEdit').activeRecord !== rec) {
                    ctl = map.getControlsBy('id','PTS-Select-Hover')[0];
                    ctl.outFeature(rec.raw);
                } else{
                    //map.getControlsBy('id','PTS-Select-Row')[0].highlight(rec.raw);
                    layer.drawFeature(rec.raw, 'select');
                }
            },
            //remove the add/load listeners from the store
            destroy: function(view) {
                store.un('add',addId, store);
                store.un('load',addId, store);
            },
            scope: this
        });
    },

    /**
     * FeatureGrid deselect handler
     *
     * Commit edits and make sure the proper style is applied
     * when a grid row is deselected.
     */
    onFeatureGridDeselect: function(rm, rec, idx) {
        var cell = rm.view.ownerCt.getPlugin('cellEdit');

        cell.completeEdit();
        rm.selectControl.unselect(rec.raw);
    }
});
