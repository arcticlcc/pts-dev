/**
 * Store of SpatialFormats for lookups, comboboxes
 */

Ext.define('PTS.store.SpatialFormats', {
    extend: 'Ext.data.Store',

    fields: [{
        name: 'spatialformatid',
        type: 'int'
    }, {
        name: 'codename',
        type: 'string'
    }, {
        name: 'description'
    }],
    proxy: {
        type: 'rest',
        url: '../spatialformat',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    },
    autoLoad: true,
    sorters: [{
        property: 'codename',
        direction: 'ASC'
    }]
});
