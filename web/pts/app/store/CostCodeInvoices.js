/**
 * Store of CostCodeInvoices.
 */
Ext.define('PTS.store.CostCodeInvoices', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.CostCodeInvoice',

    autoLoad: false,
    autoSync: false
});
