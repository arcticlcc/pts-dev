/**
 * Store of contact purchase requests.
 */
Ext.define('PTS.store.PurchaseRequests', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.PurchaseRequest',

    autoLoad: false,
    autoSync: false,
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/purchaserequest',
        reader: {
            type: 'json',
            root: 'data'
        },
        writer: {
            type: 'json'
        }
    }
});
