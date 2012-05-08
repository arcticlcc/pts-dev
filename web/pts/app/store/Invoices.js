/**
 * Store of invoices.
 */
Ext.define('PTS.store.Invoices', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Invoice',

    autoLoad: false,
    autoSync: false
});
