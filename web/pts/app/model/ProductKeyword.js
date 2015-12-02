/**
 * Product Keyword model.
 */

Ext.define('PTS.model.ProductKeyword', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'productkeywordid',
            type: 'integer',
            useNull: true,
            persist: false
        }, {
            name: 'keywordid',
            type: 'mystring',
            useNull: true
        }, {
            name: 'productid',
            type: 'integer',
            useNull: true
        }, {
            name: 'text',
            type: 'mystring',
            useNull: true,
            persist: false
        }, {
            name: 'definition',
            type: 'mystring',
            useNull: true,
            persist: false
        }

    ],
    idProperty: 'productkeywordid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/productkeyword',
        api: {
            read: PTS.baseURL + '/productkeywordlist'
        },
        reader: {
            type: 'json'
        },
        appendId: true
    }
});
