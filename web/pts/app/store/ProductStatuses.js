/**
 * @class PTS.store.ProductStatuses
 * Store of product status.
 */
Ext.define('PTS.store.ProductStatuses', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProductStatus',

    autoLoad: false,
    autoSync: false,
    sorters: [
        { property: 'effectivedate', direction : 'DESC' },
        { property: 'productstatusid', direction : 'DESC' }
    ]
});
