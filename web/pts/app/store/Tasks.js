/**
 * File: app/store/Tasks.js
 * Description: Task store.
 * TODO: page the grid??
 */

Ext.define('PTS.store.Tasks', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Task',

    autoLoad: true,
    storeId: 'Tasks',
    pageSize: PTS.Defaults.pageSize,
    sorters: [
        'duedate'
    ]
});
