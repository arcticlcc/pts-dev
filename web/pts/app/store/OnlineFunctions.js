/**
 * Store of OnlineFunctions for lookups, comboboxes
 */

Ext.define('PTS.store.OnlineFunctions', {
    extend: 'Ext.data.Store',

    fields: [{
        name: 'onlinefunctionid',
        type: 'int'
    }, {
        name: 'codename',
        type: 'string'
    }, {
        name: 'description'
    }],
    proxy: {
        type: 'rest',
        url: '../onlinefunction',
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
