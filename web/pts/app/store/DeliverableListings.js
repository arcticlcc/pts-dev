/**
 * DeliverableListings store.
 */

Ext.define('PTS.store.DeliverableListings', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableListing',

    autoLoad: true,
    remoteSort: true,
    remoteFilter: true,
    storeId: 'DeliverableListings',
    pageSize: PTS.Defaults.pageSize,
    sorters: [
        'duedate'
    ],
    filters: [
        {
            property: 'dayspastdue',
            value   : ['>',0]
        }/*,
        {
            property: 'receiveddate',
            value   : ['null']
        }*/
    ]
});
