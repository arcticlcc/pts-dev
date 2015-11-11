/**
 * ProductKeywords store.
 */

Ext.define('PTS.store.ProductKeywords', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProductKeyword',

    clearOnLoad: true,
    autoLoad: false,
    sorters: {
        property: 'text',
        direction: 'ASC'
    }
});
