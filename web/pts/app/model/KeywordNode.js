/**
 * KeywordNode model.
 */

Ext.define('PTS.model.KeywordNode', {
    extend: 'PTS.model.Base',
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
