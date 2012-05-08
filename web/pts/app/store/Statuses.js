/**
 * @class PTS.store.Statuses
 * Store of deliverable status types.
 */
Ext.define('PTS.store.Statuses', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Status',

    autoLoad: true
});
