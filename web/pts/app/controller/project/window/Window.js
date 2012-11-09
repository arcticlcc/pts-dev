/**
 * Controller for Project Window
 */
Ext.define('PTS.controller.project.window.Window', {
    extend: 'Ext.app.Controller',

    views: [
        'project.window.Window'/*,
        'project.form.ProjectForm'*/
    ],
    stores: [
        'ProjectComments',
        'ProjectVectors'
    ],
    refs: [{
        ref: 'projectWindow',
        selector: 'projectwindow'
    },{
        ref: 'projectForm',
        selector: 'projectwindow projectform'
    },{
        ref: 'projectMap',
        selector: 'projectwindow projectmap'
    },{
        ref: 'featureGrid',
        selector: 'projectwindow #featureGrid'
    }],

    init: function() {

        var pf = this.getController('project.form.ProjectForm'),
            pc = this.getController('project.window.ProjectContacts'),
            pa = this.getController('project.window.ProjectAgreements'),
            pk = this.getController('project.window.ProjectKeywords');
        // Remember to call the init method manually
        pf.init();
        pc.init();
        pa.init();
        pk.init();

        this.control({
            'projectwindow [action=closewindow]': {
                click: this.closeWindow
            },
            'projectwindow': {
                beforeclose: this.onBeforeClose
            },
            'projectwindow>tabpanel>commenteditgrid': {
                edit: this.onCommentRowEdit
            },
            'projectwindow projectmap': {
                beforerender: this.onProjectMapBeforeRender
            },
            'projectwindow projectmap maptoolbar button#modify': {
                toggle: this.onModifyBtnToggle
            },
            'projectwindow #featureGrid gridview': {
                viewready: this.onFeatureGridReady
            },
            'projectwindow #featureGrid': {
                deselect: this.onFeatureGridDeselect
            }
        });
    },

    /**
     * Closes the project window.
     */
    closeWindow: function() {
        this.getProjectWindow().close();
    },

    /**
     * The project window close event.
     */
    onBeforeClose: function() {
        //unbind the ProjectVectors store
        this.getProjectVectorsStore().unbind();

        this.application.fireEvent('closeproject');
    },

    /**
     * Update the record in the commenteditgrid store with the projectid.
     */
    onCommentRowEdit: function(editor, e) {
        var model = this.getProjectForm().getRecord(),
            id = model.getId();

        editor.record.set('projectid',id);
        editor.store.sync();
    },

    /**
     * ProjectMap beforerender listener
     */
    onProjectMapBeforeRender: function(mapPanel) {
        var ctl,
            grid = this.getFeatureGrid();

        //select on hover, proper way to do this would be to extend
        //the SelectFeature control
        ctl = new OpenLayers.Control.SelectFeature(mapPanel.projectVectors,{
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
            overFeature: function(feature) {
                var layer = feature.layer;

                if(this.hover) {
                    if(this.highlightOnly) {
                        this.highlight(feature);
                    } else if(OpenLayers.Util.indexOf(
                        layer.selectedFeatures, feature) == -1) {
                        this.select(feature);
                    }
                }

                var rec = grid.getStore().getByFeature(feature),
                    row = grid.getView().getNode(rec),
                    rowEl = Ext.get(row);

                rowEl.addCls('pts-vector-highlight');
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

                    rowEl.removeCls('pts-vector-highlight');
                }
            }
        });
            /*over = function(feature) {
                var rec = grid.getStore().getByFeature(feature),
                    row = grid.getView().getNode(rec),
                    rowEl = Ext.get(row);

                rowEl.addCls('pts-vector-highlight');
            },
            out = function(feature) {
                var rec = grid.getStore().getByFeature(feature),
                    row = grid.getView().getNode(rec),
                    rowEl = Ext.get(row);

                rowEl.removeCls('pts-vector-highlight');
            };*/

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
        /*ctl.handlers.hover = new OpenLayers.Handler.Feature(ctl, ctl.layer,{
            "over": over,
            "out": out
        }, ctl.geometryTypes);*/

        this.getProjectVectorsStore().bind(mapPanel.projectVectors);
    },

    /**
     * MapToolbar Modify button toggle listener
     *
     * Use the ModifyFeature control to select vector tied
     * to currently selected grid row, if any.
     */
    onModifyBtnToggle: function(btn, pressed) {
        var map,
            sel = this.getFeatureGrid().getSelectionModel().selected;

        if(pressed && sel.length === 1) {
            map = btn.up('projectmap').map;
            map.getControlsBy('id','PTS-Modify-Feature')[0].selectFeature(sel.first().raw);
        }
    },

    /**
     * FeatureGrid viewready listener
     *
     * If the modifyfeature control is active, we call it's
     * selectFeature method when a grid row is selected.
     */
    onFeatureGridReady: function(grid) {
        var ctl,
            sel  = grid.getSelectionModel().selectControl,
            hover = this.getProjectMap().map.getControlsBy('id','PTS-Select-Hover')[0];

        sel.onSelect = function(feature) {
            ctl = this.map.getControlsBy('id','PTS-Modify-Feature')[0];

            if(ctl.active) {
                ctl.selectFeature(feature);
            }
        };

        grid.on({
            itemmouseenter: function(grid, rec) {
                if(grid.ownerCt.getPlugin('cellEdit').activeRecord !== rec) {
                    var ctl = rec.raw.layer.map.getControlsBy('id','PTS-Select-Hover')[0];
                    ctl.highlight(rec.raw);
                }
            },
            itemmouseleave: function(grid, rec) {
                var ctl,
                    layer = rec.raw.layer,
                    map = layer.map;

                if(grid.ownerCt.getPlugin('cellEdit').activeRecord !== rec) {
                    ctl = map.getControlsBy('id','PTS-Select-Hover')[0];
                    ctl.unhighlight(rec.raw);
                } else{
                    //map.getControlsBy('id','PTS-Select-Row')[0].highlight(rec.raw);
                    layer.drawFeature(rec.raw, 'select');
                }
            },
            scope: this
        });
    },

    /**
     * FeatureGrid deselect listener
     *
     * Commit edits and make sure the proper style is applied
     * when a grid row is deselected.
     */
    onFeatureGridDeselect: function(rm, rec, idx) {
        var cell = rm.view.ownerCt.getPlugin('cellEdit');//,
            //layer = rec.raw.layer,
            //edit = cell.activeRecord;

        cell.completeEdit();
        rm.selectControl.unselect(rec.raw);
        /*if(edit == rec) {
            layer.drawFeature(rec.raw, 'select');
        } else {
            layer.drawFeature(rec.raw, 'default');
        }*/
    }
});
