/**
 * Store of notice types.
 */
Ext.define('PTS.store.Notices', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Notice',

    autoLoad: true,
    sorters: [
        {
            property : 'priority',
            direction: 'ASC'
        }
    ]
});
