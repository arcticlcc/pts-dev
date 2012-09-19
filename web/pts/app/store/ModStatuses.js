/**
 * @class PTS.store.ModStatuses
 * Store of modification status.
 */
Ext.define('PTS.store.ModStatuses', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ModStatus',

    autoLoad: false,
    autoSync: false
});
