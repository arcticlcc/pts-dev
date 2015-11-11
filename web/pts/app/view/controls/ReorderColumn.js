/**
 * Column Action that allows row order to be changed and persisted.
 */
Ext.define('PTS.view.controls.ReorderColumn', {
    extend: 'Ext.grid.column.Action',
    alias: 'widget.reordercolumn',
    //requires: ['PTS.store.Positions'],

    header: 'Priority',
    tooltip: 'The priority is set by order of appearance.',

    constructor: function(config) {
        var me = this,
            cfg = Ext.apply({}, config);

        Ext.apply(cfg, {
            width: 50,
            items: [{
                getClass: function(v, meta, rec, rowIndex) { //Return a class from a function
                    if (rowIndex > 0) {
                        this.items[0].tooltip = 'Move up';
                        return 'pts-arrow-up';
                    } else {
                        return 'pts-arrow-up-disabled';
                    }
                },
                handler: function(grid, rowIndex, colIndex) {
                    if (rowIndex > 0) {
                        var store = grid.getStore(),
                            row, rowEl,
                            rec = store.getAt(rowIndex);
                        store.removeAt(rowIndex);
                        //to prevent sending a delete request on sync
                        //we have to remove the record from the stores removed[]
                        if (!rec.phantom) {
                            Ext.Array.remove(store.removed, rec);
                        }
                        store.insert(rowIndex - 1, rec);
                        row = grid.getNode(rowIndex - 1);
                        rowEl = Ext.get(row);
                        rowEl.addCls('pts-grid-row-hilite');
                        rowEl.highlight('ffff9c', {
                            attr: "backgroundColor",
                            easing: 'easeIn',
                            duration: 1500,
                            callback: function() {
                                rowEl.removeCls('pts-grid-row-hilite');
                            },
                            scope: rowEl
                        });
                    }
                }
            }, {
                getClass: function(v, meta, rec, rowIndex, colIndex, store) {
                    if (rowIndex + 1 !== store.getCount()) {
                        this.items[1].tooltip = 'Move down';
                        return 'pts-arrow-down';
                    } else {
                        return 'pts-arrow-down-disabled';
                    }
                },
                handler: function(grid, rowIndex, colIndex) {
                    if (rowIndex - 1 < grid.getStore().getCount()) {
                        var store = grid.getStore(),
                            row, rowEl,
                            rec = store.getAt(rowIndex);
                        store.removeAt(rowIndex);
                        //to prevent sending a delete request on sync
                        //we have to remove the record from the stores removed[]
                        if (!rec.phantom) {
                            Ext.Array.remove(store.removed, rec);
                        }
                        store.insert(rowIndex + 1, rec);
                        row = grid.getNode(rowIndex + 1);
                        rowEl = Ext.get(row);
                        rowEl.addCls('pts-grid-row-hilite');
                        rowEl.highlight('ffff9c', {
                            attr: "backgroundColor",
                            easing: 'easeIn',
                            duration: 1500,
                            callback: function() {
                                rowEl.removeCls('pts-grid-row-hilite');
                            },
                            scope: rowEl
                        });
                    }
                }
            }]
        });
        me.callParent([cfg]);
    }
});
