/**
 * Store of Topic Categories.
 */

Ext.define('PTS.store.TopicCategories', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.TopicCategory',

    autoLoad: true,
    sorters: [
        {
            property : 'codename',
            direction: 'ASC'
        }
    ]
});
