/**
 * Store of Deliverable Types.
 * Creates the TaskTypes store on load.
 */

Ext.define('PTS.store.DeliverableTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableType',

    autoLoad: true,
    listeners: {
        load: { //create store for task types
            fn: function(store, recs, success, op){
                    var tdata = [],
                        tstore = Ext.getStore('TaskTypes');

                    store.each(function(rec) {
                        var txt = 'task'.toLowerCase(),
                            itm = rec.get('type');

                        if(itm.indexOf(txt) > -1) {
                            tdata.push(rec);
                            store.remove(rec);
                        }
                    });

                if(undefined === tstore) {
                    Ext.create('Ext.data.Store', {
                        storeId: 'TaskTypes',
                        model: 'PTS.model.DeliverableType',
                        data : tdata
                    });
                }else {
                    tstore.loadRecords(tdata,{addRecords: false});
                }
            }
        }
    }
});
