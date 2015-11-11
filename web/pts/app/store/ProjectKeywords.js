/**
 * ProjectKeywords store.
 */

Ext.define('PTS.store.ProjectKeywords', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectKeyword',

    clearOnLoad: true,
    autoLoad: false,
    sorters: {
        property: 'text',
        direction: 'ASC'
    }
});
