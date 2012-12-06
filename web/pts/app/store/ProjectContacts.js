/**
 * Store of project contacts with computed attributes.
 */
Ext.define('PTS.store.ProjectContacts', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectContact',
    requires: [
        'PTS.store.ProjectFunders',
        'PTS.store.ProjectInvoicers',
        'PTS.store.ProjectRecipients',
        'PTS.store.NoticeRecipients'
        ],

    autoLoad: false,
    listeners: {
        /*load: { //update store for project funders based on projectcontacts
            fn: function(store, recs, success, op){
            console.info('load');
                    var data = [],
                        store = Ext.getStore('ProjectFunders');

                    pstore.each(function(rec) {
                        var id = 4,
                            itm = rec.get('roletypeid');

                        if(4 == itm) {
                            data.push(rec);
                        }
                    });

                    store.loadRecords(data,{addRecords: false});
            }
        },*/
        //TODO: this would be more efficient using add,remove,update events
        //TODO: add constraint in database to prevent removal of assigned funders
        //TODO: invoicer roles should be configurable in ini
        datachanged: { //update store for project funders/invoicers based on projectcontacts
            fn: function(store, recs, success, op){
                    var data = [], //project funders
                        idata = [], //invoicers,
                        rdata = [], //recipient
                        ndata = [], //notice
                        invoicerRoles = [1,5,6,7,10,11], //roletypes allowed as invoice contact
                        invoicerIds = [], //invoicers added to projectinvoicers store
                        noticeRoles = [5,6,7], //roletypes allowed as notice contact
                        noticeIds = [], //contacts added to noticerecipients store
                        pstore = Ext.getStore('ProjectFunders'),
                        istore = Ext.getStore('ProjectInvoicers'),
                        rstore = Ext.getStore('ProjectRecipients'),
                        nstore = Ext.getStore('NoticeRecipients');

                    store.each(function(rec) {
                        var itm = rec.get('roletypeid'),
                            cid = rec.get('contactid');

                        if(4 === itm || 10 === itm) {
                            //add a copy of the record to prevent conflicts with existing model
                            data.push(rec.copy());
                        }
                        //add invoicers if not already present
                        if(Ext.Array.indexOf(invoicerRoles, itm) > -1 && Ext.Array.indexOf(invoicerIds, cid) === -1) {
                            idata.push(rec.copy());
                            invoicerIds.push(cid);
                        }
                        //add notice recip if not already present
                        if(Ext.Array.indexOf(noticeRoles, itm) > -1 && Ext.Array.indexOf(noticeIds, cid) === -1) {
                            ndata.push(rec.copy());
                            noticeIds.push(cid);
                        }
                        //add funding recipient
                        if(11 === itm) {
                            rdata.push(rec.copy());
                        }
                    });
                    pstore.loadRecords(data,{addRecords: false});
                    istore.loadRecords(idata,{addRecords: false});
                    rstore.loadRecords(rdata,{addRecords: false});
                    nstore.loadRecords(ndata,{addRecords: false});
                    return true;
            }
        }
    }
});
