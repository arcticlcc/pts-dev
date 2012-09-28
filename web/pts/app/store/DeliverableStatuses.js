/**
 * @class PTS.store.DeliverableStatuses
 * Store of deliverable status types.
 */
Ext.define('PTS.store.DeliverableStatuses', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableStatus',

    autoLoad: true,
    sorters: [
        {
            property : 'deliverablestatusid',
            direction: 'ASC'
        }
    ]
});
