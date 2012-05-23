/**
 * File: app/store/ProjectIDs.js
 * Description: Store of project ids for lookups, comboboxes
 */

Ext.define('PTS.store.ProjectIDs', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Project',

    fields: [
        {
            name: 'id',
            type: 'int'
        },
        {
            name: 'projectid',
            type: 'string'
        },
        {
            name: 'title'
        }
    ],
    autoLoad: false
});
