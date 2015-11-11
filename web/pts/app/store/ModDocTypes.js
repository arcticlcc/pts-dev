/**
 * Modification Documents store.
 */
Ext.define('PTS.store.ModDocTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ModDocType',

    autoLoad: false,
    sorters: [{
        property: 'sort',
        direction: 'ASC'
    }, {
        property: 'code',
        direction: 'ASC'
    }]
});
