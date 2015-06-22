/**
 * File: app/model/Invoice.js
 * Description: Invoice model.
 */

Ext.define('PTS.model.Invoice', {
    extend: 'PTS.model.Base',
    fields: [
        {
            name: 'invoiceid',
            type: 'int',
            persist: false
        },
        {
            name: 'fundingid',
            type: 'int',
            useNull: true
        },
        {
            name: 'projectcontactid',
            type: 'int',
            useNull: true
        },
        {
            name: 'datereceived',
            type: 'mydate',
            useNull: true
        },
        {
            name: 'dateclosed',
            type: 'mydate',
            useNull: true
        },
        {
            name: 'amount',
            type: 'number',
            useNull: true
        },
        {name: 'title', type: 'mystring', useNull: true}
    ],
    idProperty: 'invoiceid',

    hasMany: [
        {model: 'PTS.model.CostCodeInvoice', name: 'costcodes'}
    ],

    proxy: {
        type: 'rest',
        url : '../invoice',
        reader: {
            type: 'json',
            root: 'data'
        },
        writer: {
            type: 'ajson'
        }
    }
});
