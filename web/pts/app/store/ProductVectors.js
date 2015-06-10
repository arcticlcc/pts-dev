/**
 * Store of product vector geometry features.
 */

Ext.define('PTS.store.ProductVectors', {
    extend: 'GeoExt.data.FeatureStore',
    model: 'PTS.model.ProductVector',

    autoLoad: false,
    sorters: [
        'name'
    ]
});
