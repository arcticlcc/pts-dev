/**
 * Store of common project vector geometry features.
 */

Ext.define('PTS.store.CommonVectors', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.CommonVector',

    autoLoad: false,
    sorters: [
        'text'
    ]
});
