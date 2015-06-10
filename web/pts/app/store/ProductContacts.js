/**
 * Store of product contacts.
 */
Ext.define('PTS.store.ProductContacts', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProductContact',
    requires: [],

    autoLoad: false
});
