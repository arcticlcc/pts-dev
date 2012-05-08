/*
 * File: app/store/ModTypes.js
 * Description: Store of Modification Types
 */

Ext.define('PTS.store.ModTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ModType',

    autoLoad: true,
    listeners: {//TODO: move to controller?
        load: { //create stores for proposal and agreement types
            fn: function(store, recs, success, op){
                    var adata = [], pdata = [],
                        pstore = Ext.getStore('ProposalTypes'),
                        astore = Ext.getStore('AgreementTypes');

                    store.each(function(rec) {
                        var txt = 'proposal'.toLowerCase(),
                            itm = rec.get('type');

                        if(!(itm.indexOf(txt)+1)) {
                            adata.push(rec);
                        } else {
                            pdata.push(rec);
                        }
                    });

                if(undefined === pstore) {
                    Ext.create('Ext.data.Store', {
                        storeId: 'ProposalTypes',
                        model: 'PTS.model.ModType',
                        data : pdata
                    });
                }else {
                    pstore.loadRecords(pdata,{addRecords: false});
                }

                if(undefined === astore) {
                    Ext.create('Ext.data.Store', {
                        storeId: 'AgreementTypes',
                        model: 'PTS.model.ModType',
                        data : adata
                    });
                }else {
                    astore.loadRecords(adata,{addRecords: false});
                }
            }
        }
    }
});
