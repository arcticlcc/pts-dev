/**
 * @class PTS.store.ModStatuses
 * Store of deliverable status types.
 */
Ext.define('PTS.store.ModStatuses', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ModStatus',

    autoLoad: false,
    autoSync: false
});
