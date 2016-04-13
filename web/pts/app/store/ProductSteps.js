/**
 * Store of product steps.
 */
Ext.define('PTS.store.ProductSteps', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProductStep',

    autoLoad: false,
    autoSync: false,
    sorters: [{
        property: 'priority',
        direction: 'ASC'
    }]
});
