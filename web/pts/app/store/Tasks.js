/**
 * File: app/store/Tasks.js
 * Description: Task store.
 */

Ext.define('PTS.store.Tasks', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Task',

    autoLoad: true,
    remoteSort: true,
    remoteFilter: true,
    storeId: 'Tasks',
    pageSize: PTS.Defaults.pageSize,
    sorters: [
        'duedate'
    ],
    filters: [{
        property: 'completed',
        value: 'false'
    }]
});
