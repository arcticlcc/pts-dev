/**
 * Store of project contacts with computed attributes.
 */

Ext.define('PTS.store.ProjectFunders', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectContact',

    autoLoad: false,
    sorters: [
        'name'
    ]
});
