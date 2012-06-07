/**
 * File: app/store/ProjectInvoicers.js
 * Description: Store of project invoicers
 * with computed attibutes.
 */

Ext.define('PTS.store.ProjectInvoicers', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectContact',

    autoLoad: false,
    sorters: [
        'name'
    ]
});
