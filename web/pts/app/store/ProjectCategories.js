/**
 * Store of Project Categories.
 */

Ext.define('PTS.store.ProjectCategories', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectCategory',

    autoLoad: true,
    sorters: [
        {
            property : 'category',
            direction: 'ASC'
        }
    ]
});
