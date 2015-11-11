/**
 * Store of Deliverable Types.
 * Creates the TaskTypes store on load.
 */

Ext.define('PTS.store.DeliverableTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableType',

    autoLoad: true,
    sorters: [{
        property: 'code',
        direction: 'ASC'
    }],
    listeners: {
        load: { //create store for task and product types
            fn: function(store, recs, success, op) {
                var tdata = [],
                    pdata = [],
                    tstore = Ext.getStore('TaskTypes'),
                    pstore = Ext.getStore('ProductTypes');

                store.each(function(itm) {
                    if (itm.get('product')) {
                        pdata.push(itm);
                    }
                });

                if (undefined === pstore) {
                    Ext.create('Ext.data.Store', {
                        storeId: 'ProductTypes',
                        model: 'PTS.model.DeliverableType',
                        data: pdata
                    });
                } else {
                    pstore.loadRecords(pdata, {
                        addRecords: false
                    });
                }

                store.each(function(rec) {
                    var txt = 'task'.toLowerCase(),
                        itm = rec.get('type');

                    if (itm.indexOf(txt) > -1) {
                        tdata.push(rec);
                        store.remove(rec);
                    }
                });

                if (undefined === tstore) {
                    Ext.create('Ext.data.Store', {
                        storeId: 'TaskTypes',
                        model: 'PTS.model.DeliverableType',
                        data: tdata
                    });
                } else {
                    tstore.loadRecords(tdata, {
                        addRecords: false
                    });
                }
            }
        }
    }
});
