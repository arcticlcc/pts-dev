/**
 * KeywordNode model.
 */

Ext.define('PTS.model.KeywordNode', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'keywordid',
            type: 'string'
        },
        {
            name: 'text', type: 'mystring', useNull: true
        },
        {
            name: 'definition', type: 'mystring', useNull: true
        },
        {
            name: 'fullname', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'keywordid',

    proxy: {
        type: 'rest',
        url : '../keyword/tree',
        reader: {
            type: 'json'
        },
        appendId: true
    }
});
