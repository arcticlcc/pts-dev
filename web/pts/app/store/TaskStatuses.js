/**
 * @class PTS.store.TaskStatuses
 * Store of task status types.
 */
Ext.define('PTS.store.TaskStatuses', {
    extend: 'PTS.store.DeliverableStatuses',

    proxy: {
        type: 'rest',
        url: '../taskstatus',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});