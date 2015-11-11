/**
 * Store of EpsgCodes.
 */

Ext.define('PTS.store.EpsgCodes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.EpsgCode',

    autoLoad: false,

    remoteSort: true,
    remoteFilter: true,
    sorters: [{
        property: 'srid',
        direction: 'ASC'
    }]
});
