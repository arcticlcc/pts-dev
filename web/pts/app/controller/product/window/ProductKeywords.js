/**
 * Controller for ProductKeywords
 */
Ext.define('PTS.controller.product.window.ProductKeywords', {
    extend: 'Ext.app.Controller',

    views: [
        'product.window.ProductKeywords'
    ],
    models: [
        'KeywordNode',
        'ProductKeyword'
    ],
    stores: [
        'KeywordNodes',
        'ProductKeywords',
        'Keywords'
    ],
    refs: [{
        ref: 'productWindow',
        selector: 'productwindow'
    }, {
        ref: 'keywordTree',
        selector: 'productwindow productkeywords #keywordTree'
    }, {
        ref: 'keywordSearch',
        selector: 'productwindow productkeywords #keywordSearch'
    }, {
        ref: 'productKeywords',
        selector: 'productwindow #productKeywords'
    }],

    init: function() {

        this.control({
            /*'productwindow #keywordTree treeview': {
                beforedrop: this.removeKeywordsByDrag
            },*/
            'productwindow productkeywords #keywordTree': {
                render: this.onRemoveTargetRender
            },
            'productwindow productkeywords #keywordSearch': {
                render: this.onRemoveTargetRender
            },
            'productwindow #productKeywords gridview': {
                itemadd: this.onItemAdd,
                beforedrop: this.onBeforeDrop
            },
            'productwindow productkeywords button[action=removekeywords]': {
                render: this.onRemoveTargetRender,
                click: this.removeKeywords
            },
            'productwindow productkeywords button[action=savekeywords]': {
                click: this.saveKeywords
            },
            'productwindow productkeywords button[action=refreshkeywords]': {
                click: this.refreshKeywords
            },
            'productwindow productkeywords templatecolumn[action=addkeyword]': {
                click: this.onActionAddClick
            }
        });

        // We listen for the application-wide events
        this.application.on({
            openproduct: this.onOpenProduct,
            saveproduct: this.onSaveProduct,
            scope: this
        });
    },

    /**
     * Set proxy based on current productid.
     * @param {Number} productid
     * @param {PTS.store.ProductKeywords}
     */
    setProxy: function(id, store) {

        //override store proxy based on productid
        store.setProxy({
            type: 'rest',
            url: '../productkeyword',
            appendId: true,
            //batchActions: true,
            api: {
                read: '../product/' + id + '/productkeywordlist'
            },
            reader: {
                type: 'json',
                root: 'data'
            },
            limitParam: undefined
        });
    },

    /**
     * Open product event.
     */
    onOpenProduct: function(id) {
        var store = this.getProductKeywordsStore();

        if (id) {
            this.setProxy(id, store);
            //load the store
            store.load();
        }
    },

    /**
     * Save product event.
     */
    onSaveProduct: function(record) {
        var store = this.getProductKeywordsStore();

        if (record) {
            this.setProxy(record.getId(), store);
            //load the productcontacts store
            store.load();
        }
    },

    /**
     * BeforeDrop listener to process drops onto the ProductKeyword grid.
     * Reject duplicates with notification.
     * TODO: update this to use dragHandlers, which is fixed in 4.1
     */
    onBeforeDrop: function(node, data, dropRec, dropPosition) {
        //Logic to prevent multiple copies
        var store = this.getProductKeywordsStore(),
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
                    newrec.push(this.getProductKeywordModel().create({
                        productid: record.get('productid'),
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
     * ItemAdd listener to process drops onto the ProductKeyword grid.
     */
    onItemAdd: function(records, index, node) {
        var pid = this.getProductWindow().productId;

        //Mark added records as dirty
        Ext.each(records, function(r) {
            if (!r.restored) {
                r.set('productid', pid);
                r.setDirty();
                r.phantom = true;
            }
        });
    },

    /**
     * Remove contacts via drag/drop.
     */
    removeKeywordsByDrag: function(node, data, overModel, dropPosition, dropFunction) {
        this.getProductKeywordsStore().remove(data.records);
        return false;
    },

    /**
     * Render listener for the delete keywords DropTargets.
     */
    onRemoveTargetRender: function(cmp) {
        var store = this.getProductKeywordsStore();

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
        var store = this.getProductKeywordsStore(),
            el = this.getProductKeywords().getEl(),
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
        var grid = this.getProductKeywords(),
            sel = grid.getSelectionModel().getSelection();

        grid.getStore().remove(sel);
    },

    /**
     * Refresh keywords action.
     */
    refreshKeywords: function() {
        var grid = this.getProductKeywords();

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
            dropRec = this.getProductKeywordsStore().last();

        //use the onBeforeDrop method to add the record
        this.onBeforeDrop(undefined, data, dropRec);
    }
});
