/**
 * Controller for ProjectKeywords
 */
Ext.define('PTS.controller.project.window.ProjectKeywords', {
    extend: 'Ext.app.Controller',

    views: [
        'project.window.ProjectKeywords'
    ],
    models: [
        'KeywordNode',
        'ProjectKeyword'
    ],
    stores: [
        'KeywordNodes',
        'ProjectKeywords',
        'Keywords'
    ],
    refs: [{
        ref: 'projectWindow',
        selector: 'projectwindow'
    }, {
        ref: 'keywordTree',
        selector: 'projectwindow projectkeywords #keywordTree'
    }, {
        ref: 'keywordSearch',
        selector: 'projectwindow projectkeywords #keywordSearch'
    }, {
        ref: 'projectKeywords',
        selector: 'projectwindow #projectKeywords'
    }],

    init: function() {

        this.control({
            /*'projectwindow #keywordTree treeview': {
                beforedrop: this.removeKeywordsByDrag
            },*/
            'projectwindow projectkeywords #keywordTree': {
                render: this.onRemoveTargetRender
            },
            'projectwindow projectkeywords #keywordSearch': {
                render: this.onRemoveTargetRender
            },
            'projectwindow #projectKeywords gridview': {
                itemadd: this.onItemAdd,
                beforedrop: this.onBeforeDrop
            },
            'projectwindow projectkeywords button[action=removekeywords]': {
                render: this.onRemoveTargetRender,
                click: this.removeKeywords
            },
            'projectwindow projectkeywords button[action=savekeywords]': {
                click: this.saveKeywords
            },
            'projectwindow projectkeywords button[action=refreshkeywords]': {
                click: this.refreshKeywords
            },
            'projectwindow projectkeywords templatecolumn[action=addkeyword]': {
                click: this.onActionAddClick
            }
        });

        // We listen for the application-wide events
        this.application.on({
            openproject: this.onOpenProject,
            saveproject: this.onSaveProject,
            scope: this
        });
    },

    /**
     * Set proxy based on current projectid.
     * @param {Number} projectid
     * @param {PTS.store.ProjectKeywords}
     */
    setProxy: function(id, store) {
        var read = PTS.baseURL + '/project/' + id + '/projectkeywordlist';

        if (store.getProxy().api.read !== read) {
            //override store proxy based on projectid
            store.setProxy({
                type: 'rest',
                url: PTS.baseURL + '/projectkeyword',
                appendId: true,
                //batchActions: true,
                api: {
                    read: read
                },
                reader: {
                    type: 'json',
                    root: 'data'
                },
                limitParam: undefined
            });
        }
    },

    /**
     * Open project event.
     */
    onOpenProject: function(id) {
        var store = this.getProjectKeywordsStore();

        if (id) {
            this.setProxy(id, store);
            //load the projectcontacts store
            store.load();
        }
    },

    /**
     * Save project event.
     */
    onSaveProject: function(record) {
        var store = this.getProjectKeywordsStore();

        if (record) {
            this.setProxy(record.getId(), store);
            //load the projectkeywords store
            store.load();
        }
    },

    /**
     * BeforeDrop listener to process drops onto the ProjectKeyword grid.
     * Reject duplicates with notification.
     * TODO: update this to use dragHandlers, which is fixed in 4.1
     */
    onBeforeDrop: function(node, data, dropRec, dropPosition) {
        //Logic to prevent multiple copies
        var store = this.getProjectKeywordsStore(),
            draggedRecords = data.records,
            ln = draggedRecords.length,
            errors = '',
            removed = store.getRemovedRecords(),
            pos = dropPosition === 'before' ? store.indexOf(dropRec) : store.indexOf(dropRec) + 1,
            i, record, newrec = [];


        for (i = 0; i < ln; i++) {
            record = draggedRecords[i];
            //reject duplicates
            if (store.findExact('keywordid', record.getId()) !== -1) {
                errors += '<br /> ' + record.get('text');
            } else {
                //check to see if the record was "removed"
                if (removed.length > 0 && Ext.Array.some(removed, function(r) {
                        if (r.get('keywordid') === record.get('keywordid')) {
                            record = r;
                            return true;
                        }
                    })) {
                    record.reject();
                    record.restored = true;
                    newrec.push(record);
                    //we have to manually remove the record
                    Ext.Array.remove(store.removed, record);
                } else {
                    newrec.push(this.getProjectKeywordModel().create({
                        projectid: record.get('projectid'),
                        keywordid: record.get('keywordid'),
                        text: record.get('text')
                    }));
                }
            }
        }
        //insert new records
        if (newrec.length) {
            store.insert(pos, newrec);
        }

        //process errors
        if (errors !== '') {
            Ext.create('widget.uxNotification', {
                title: 'Notice',
                iconCls: 'ux-notification-icon-information',
                html: 'The following keywords have already been added:<br />' +
                    errors
            }).show();
        }
        //we've already processed the records
        return false;
    },

    /**
     * ItemAdd listener to process drops onto the ProjectKeyword grid.
     */
    onItemAdd: function(records, index, node) {
        var pid = this.getProjectWindow().projectId;

        //Mark added records as dirty
        Ext.each(records, function(r) {
            if (!r.restored) {
                r.set('projectid', pid);
                r.setDirty();
                r.phantom = true;
            }
        });
    },

    /**
     * Remove contacts via drag/drop.
     */
    removeKeywordsByDrag: function(node, data, overModel, dropPosition, dropFunction) {
        this.getProjectKeywordsStore().remove(data.records);
        return false;
    },

    /**
     * Render listener for the delete keywords DropTargets.
     */
    onRemoveTargetRender: function(cmp) {
        var store = this.getProjectKeywordsStore();

        Ext.create('Ext.dd.DropTarget', cmp.getEl(), {
            ddGroup: 'deletekeywords',

            notifyDrop: function(source, ev, data) {
                store.remove(data.records);
                return true;
            }
        });
    },
    /**
     * Save Keywords.
     */
    saveKeywords: function() {
        var store = this.getProjectKeywordsStore(),
            el = this.getProjectKeywords().getEl(),
            isDirty = !!(store.getRemovedRecords().length + store.getUpdatedRecords().length +
                store.getNewRecords().length);

        //mask panel
        if (isDirty) {
            el.mask('Saving...');
        }
        //loop thru records and set the priority
        /*store.each(function() {
            var rec = this,
                priority = rec.get('priority'),
                idx  = store.indexOf(rec);

            if(priority !== idx) {
                rec.set('priority', idx);
            }
        });*/

        //TODO: Fixed in 4.1?
        //the failure and callback function won't be called on HTTP exception,
        //we need to overload the getBatchListeners method and add exception
        //handling directly to the batch, onBatchException is not defined by default
        //http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
        store.getBatchListeners = function() {
            var me = store,
                listeners = {
                    scope: me,
                    exception: function(batch, op) {
                        el.unmask();
                        //set the global app error
                        PTS.app.setError('There was an error saving the keywords.</br>Error:' + PTS.app.getError());
                        /*Ext.create('widget.uxNotification', {
                            title: 'Error',
                            iconCls: 'ux-notification-icon-error',
                            html: 'There was an error saving the keywords.</br>Error:' + PTS.app.getError(),
                        }).show();*/
                    }
                };

            if (me.batchUpdateMode === 'operation') {
                listeners.operationcomplete = me.onBatchOperationComplete;
            } else {
                listeners.complete = me.onBatchComplete;
            }

            return listeners;
        };

        store.sync({
            success: function() {
                el.unmask();
                //console.log('Keywords saved');
            },
            failure: function() {
                el.unmask();
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'There was an error saving the keywords.</br>Error:' + PTS.app.getError()
                }).show();
            },
            callback: function() {

            }
        });
    },

    /**
     * Remove keywords action.
     */
    removeKeywords: function() {
        var grid = this.getProjectKeywords(),
            sel = grid.getSelectionModel().getSelection();

        grid.getStore().remove(sel);
    },

    /**
     * Refresh keywords action.
     */
    refreshKeywords: function() {
        var grid = this.getProjectKeywords();

        grid.getStore().load({
            callback: function(records, operation, success) {
                //hack to clear the removed records array
                grid.getStore().removed = [];
            }
        });
    },

    /**
     * Add keywords action.
     */
    onActionAddClick: function(view, el, rowIndex, colIndex) {
        var rec = view.getStore().getAt(rowIndex),
            data = {
                records: [rec]
            },
            dropRec = this.getProjectKeywordsStore().last();

        //use the onBeforeDrop method to add the record
        this.onBeforeDrop(undefined, data, dropRec);
    }
});
