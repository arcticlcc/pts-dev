/**
 * Store of product group ids for lookups, comboboxes
 */

Ext.define('PTS.store.ProductGroupIDs', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Product',

    fields: [{
        name: 'productid',
        type: 'int'
    }, {
        name: 'projectid',
        type: 'int'
    },{
        name: 'projectcode',
        type: 'string'
    }, {
        name: 'title'
    }, {
        name: 'isgroup',
        type: 'myboolean'
    }],
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/productgrouplist',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    },
    autoLoad: false,
    sorters: [{
        property: 'projectcode',
        direction: 'DESC'
    }, {
        property: 'title',
        direction: 'ASC'
    }]
});
