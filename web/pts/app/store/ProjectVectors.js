/**
 * Store of project vector geometry features.
 */

Ext.define('PTS.store.ProjectVectors', {
    extend: 'GeoExt.data.FeatureStore',
    model: 'PTS.model.ProjectVector',

    autoLoad: false,
    sorters: [
        'name'
    ]
});
