/**
 * File: app/model/CostCodeInvoice.js
 * Description: CostCodeInvoice model.
 */

Ext.define('PTS.model.CostCodeInvoice', {
    extend: 'PTS.model.Base',
    fields: [
        {
            name: 'costcodeinvoiceid',
            type: 'int',
            useNull: true
        },
        {
            name: 'costcodeid',
            type: 'int',
            useNull: true
        },
        {
            name: 'invoiceid',
            type: 'int',
            useNull: true
        },
        {
            name: 'datecharged',
            type: 'mydate',
            useNull: true
        },
        {
            name: 'amount',
            type: 'number',
            useNull: true
        }
    ],
    idProperty: 'costcodeinvoiceid',

    validations: [{
        type: 'length',
        field: 'costcodeid',
        min: 1
    }, {
        type: 'length',
        field: 'invoiceid',
        min: 1
    }, {
        type: 'presence',
        field: 'datecharged'
    }, {
        type: 'presence',
        field: 'amount'
    }],

    proxy: {
        type: 'rest',
        url : '../costcodeinvoice',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
