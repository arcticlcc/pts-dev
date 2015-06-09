/**
 * Product Keyword model.
 */

Ext.define('PTS.model.ProductKeyword', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'productkeywordid',
            type: 'integer',
            useNull: true,
            persist: false
        },
        {
            name: 'keywordid',
            type: 'mystring',
            useNull: true
        },        {
            name: 'productid',
            type: 'integer',
            useNull: true
        },
        {
            name: 'text', type: 'mystring', useNull: true, persist: false
        },
        {
            name: 'definition', type: 'mystring', useNull: true, persist: false
        }

    ],
    idProperty: 'productkeywordid',

    proxy: {
        type: 'rest',
        url : '../productkeyword',
        api: {
            read: '../productkeywordlist'
        },
        reader: {
            type: 'json'
        },
        appendId: true
    }
});
