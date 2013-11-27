/**
 * ModificationComments store.
 */

Ext.define('PTS.store.ModDocStatuses', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ModDocStatus',

    autoLoad: false,
    sorters: [{
        property: 'effectivedate',
        direction: 'DESC'
    },{
        property: 'weight',
        direction: 'DESC'
    }]
});
