/**
 * Abstract grid with rowediting plugin enabled and toolbar.
 */
Ext.define('PTS.view.controls.RowEditGrid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.roweditgrid',
    requires: [
        'Ext.grid.plugin.RowEditing'
    ],

    bodyPadding: 0,

    /**
     * @cfg {Boolean} syncOnRemoveRow
     */
    syncOnRemoveRow: true,

    /**
     * @cfg {Ext.data.Store} store (required)
     * @inheritdoc Ext.panel.Table#store
     */

    /**
     * @cfg {Ext.grid.column.Column[]} columns
     * @inheritdoc Ext.panel.Table#columns
     */

    /**
     * @cfg {Object[]} extraButtons
     * Extra buttons to add to the toolbar.
     */

    /**
     * Add row.
     */
    addRow: function(btn) {
        var grid = btn.up('gridpanel'),
            store = grid.getStore(),
            model = store.getProxy().getModel(),
            rowEditing = grid.getPlugin('roweditplugin');

        //rowEditing.cancelEdit();

        store.insert(0, Ext.create(model));
        rowEditing.startEdit(0, 0);
    },

    /**
     * Remove row.
     */
    removeRow: function(btn) {
        var grid = btn.up('gridpanel'),
            el = grid.getEl(),
            store = grid.getStore(),
            //sm = grid.getSelectionModel(),
            //rowEditing = grid.getPlugin('roweditplugin');
            selection = grid.getView().getSelectionModel().getSelection()[0];

        if (grid.fireEvent('beforeremoverow', selection, store) !== false) {
            if (selection) {
                store.remove(selection);
            }
            //TODO: Fixed in 4.1?
            //the failure and callback function won't be called on HTTP exception,
            //we need to overload the getBatchListeners method and add exception
            //handling directly to the batch, onBatchException is not defined by default
            //http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
            store.getBatchListeners = function() {
                var me = store,
                    sel = selection, //the selected record
                    listeners = {
                        scope: me,
                        exception: function(batch, op) {
                            var rec;

                            el.unmask();
                            //if a destroy operation fails we need to add the record back to the store
                            if (op.action === "destroy") {
                                rec = op.records[0];
                                rec.reject(); //reject changes
                                Ext.Array.remove(store.removed, rec); //remove the record from the store's removed array
                                store.insert(sel.index, rec); //insert back into the store at the same position

                            }
                        }
                    };

                if (me.batchUpdateMode === 'operation') {
                    listeners.operationcomplete = me.onBatchOperationComplete;
                } else {
                    listeners.complete = me.onBatchComplete;
                }

                return listeners;
            };

            if (!selection.phantom && grid.syncOnRemoveRow) {
                el.mask('Deleting...');
                store.sync({
                    success: function() {
                        el.unmask();
                        grid.fireEvent('removerow', selection, store);
                    }
                });
            } else {
                grid.fireEvent('beforeremoverow', selection, store);
            }
        }
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            plugins: [
                Ext.create('Ext.grid.plugin.RowEditing', {
                    clicksToEdit: 1,
                    autoCancel: false,
                    errorSummary: false,
                    pluginId: 'roweditplugin'
                })
            ],
            tbar: [{
                text: 'Add',
                iconCls: 'pts-menu-addbasic',
                handler: this.addRow
            }, {
                itemId: 'removeRow',
                text: 'Remove',
                iconCls: 'pts-menu-deletebasic',
                handler: this.removeRow,
                disabled: true
            }]
        });

        Ext.each(me.extraButtons, function(b) {
            me.tbar.push(b);
        });

        me.callParent(arguments);
        me.addEvents(
            /**
             * @event beforeremoverow
             * Fires before a row is removed.
             * Return false to cancel removal.
             * @param {Ext.data.Model} record
             * @param {Ext.data.Store} store
             */
            'beforeremoverow',
            /**
             * @event removerow
             * Fires after a row is removed.
             * If {@link #syncOnRemoveRow} is true, the event fires on sync success
             * @param {Ext.data.Model} record
             * @param {Ext.data.Store} store
             */
            'removerow'
        );
        me.getSelectionModel().on('selectionchange', function(selModel, selections) {
            me.down('#removeRow').setDisabled(selections.length === 0);
        });
    }

});
