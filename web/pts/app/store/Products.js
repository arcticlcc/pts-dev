/**
 * File: app/store/Product.js
 * Description: Store of products
 */

Ext.define('PTS.store.Products', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Product',

    //autoLoad: true,
    remoteSort: true,
    remoteFilter: true,
    pageSize: PTS.Defaults.pageSize,
    sorters: [
        { property: 'projectcode', direction : 'DESC' }
    ]
});
