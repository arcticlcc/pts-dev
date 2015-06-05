/**
 * Abstract form containing linked gridpanel.
 */
Ext.define('PTS.view.controls.GridForm', {
    extend: 'Ext.form.Panel',
    alias: 'widget.gridform',
    requires: [],

    layout: 'border', // Specifies that the items will now be arranged in columns
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
     * @cfg {Ext.form.Field[]} fields
     * @inheritdoc Ext.form.Field#items
     */

    /**
     * @cfg {Object[]} extraButtons
     * Extra buttons to add to the toolbar.
     */

    /**
     * Add row.
     */
    addRow: function(btn) {
        var form = btn.up('gridform'),
            store = form.down('gridpanel').getStore(),
            model = store.getProxy().getModel(),
            rec = Ext.create(model);

        form.loadRecord(rec);
        form.fireEvent('loadrecord', rec);
        form.down('#formpanel').enable();
    },

    /**
     * Save row.
     */
    saveRow: function(btn) {
        var form = btn.up('gridform'),
            rec = form.getRecord(),
            el = form.down('#formpanel').getEl(),
            grid = form.down('gridpanel'),
            store = grid.getStore();
            //mask = new Ext.LoadMask(pnl,'Saving...');

        el.mask('Saving...');
        form.getForm().updateRecord(rec);

        rec.save({
            success: function(model, op) {
                var idx = store.indexOfId(model.getId()),
                    sm = grid.getSelectionModel();

                //load the model to get desired trackresetonload behavior
                form.loadRecord(model);

                if (idx === -1) {
                    store.add(model);
                    sm.select(model);
                } else {
                    sm.select(idx);
                }

                el.unmask();
            },
            failure: function(model, op) {
                el.unmask();
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'There was an error saving the link.</br>Error: ' + PTS.app.getError()
                }).show();
            },
            scope: this
        });
    },

    /**
     * Remove row.
     */
    removeRow: function(btn) {
        var form = btn.up('gridform'),
            grid = form.down('gridpanel'),
            el = grid.getEl(),
            store = grid.getStore(),
            selection = grid.getView().getSelectionModel().getSelection()[0];

        if (form.fireEvent('beforeremoverow', selection, store) !== false) {
            if (selection) {
                store.remove(selection);
            }
            //TODO: Fixed in 4.1?
            //the failure and callback function won't be called on HTTP
            // exception,
            //we need to overload the getBatchListeners method and add exception
            //handling directly to the batch, onBatchException is not defined by
            // default
            //http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
            store.getBatchListeners = function() {
                var me = store, sel = selection, //the selected record
                listeners = {
                    scope: me,
                    exception: function(batch, op) {
                        var rec;

                        el.unmask();
                        //if a destroy operation fails we need to add the record
                        // back to the store
                        if (op.action === "destroy") {
                            rec = op.records[0];
                            rec.reject();
                            //reject changes
                            Ext.Array.remove(store.removed, rec);
                            //remove the record from the store's removed array
                            store.insert(sel.index, rec);
                            //insert back into the store at the same position

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

            if (!selection.phantom && form.syncOnRemoveRow) {
                el.mask('Deleting...');
                store.sync({
                    success: function() {
                        el.unmask();
                        form.down('#formpanel').disable();
                        form.fireEvent('removerow', selection, store);
                    }
                });
            } else {
                form.fireEvent('beforeremoverow', selection, store);
            }
        }
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {

            fieldDefaults: {
                labelAlign: 'left',
                msgTarget: 'side'
            },
            items: [{
                //columnWidth: 0.60,
                xtype: 'gridpanel',
                region: 'center',
                autoScroll: true,
                store: me.store,
                //title:'Online Resource',

                columns: me.columns,

                dockedItems:[{
                    xtype: 'pagingtoolbar',
                    store: me.store,   // same store GridPanel is using
                    dock: 'top',
                    displayInfo: true,
                    plugins: [
                        Ext.create('Ext.ux.grid.PrintGrid', {
                            printHidden: true
                        }),
                        Ext.create('Ext.ux.grid.SaveGrid', {})
                    ]
                }],

                listeners: {
                    selectionchange: function(model, records) {
                        var rec = records[0];

                        if (rec) {
                            var form = this.up('form');

                            form.getForm().loadRecord(rec);
                            form.fireEvent('loadrecord', rec);
                            form.down('#formpanel').enable();
                        }

                        this.up('gridform').down('#removeRow').setDisabled(records.length === 0);
                    },
                    viewready: function(grid) {
                        if(grid.getStore().count() > 0) {
                            grid.getSelectionModel().select(0);
                        }
                    }
                }
            }, {
                //columnWidth: 0.4,
                //margin: '0 0 0 10',
                flex: 1,
                bodyPadding: 10,
                xtype: 'panel',
                itemId: 'formpanel',
                region: 'south',
                disabled: true,
                split: true,
                title: 'Link Details',
                layout: 'anchor',
                defaults: {
                    anchor: '70%',
                    labelWidth: 90,
                    allowBlank: false
                },
                defaultType: 'textfield',
                items: me.fields,
                tbar: [{
                    xtype: 'button',
                    text: 'Save',
                    iconCls: 'pts-menu-savebasic',
                    formBind: true,
                    handler: this.saveRow
                }]
            }],
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
         * @event loadform
         * Fires after a record is loaded into the form.
         * @param {Ext.data.Model} record
         */
        'loadform',
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
        'removerow');
    }
});
