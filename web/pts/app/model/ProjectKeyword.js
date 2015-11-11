/**
 * Project Keyword model.
 */

Ext.define('PTS.model.ProjectKeyword', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'projectkeywordid',
            type: 'integer',
            useNull: true,
            persist: false
        }, {
            name: 'keywordid',
            type: 'mystring',
            useNull: true
        }, {
            name: 'projectid',
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
    idProperty: 'projectkeywordid',

    proxy: {
        type: 'rest',
        url: '../project/keyword',
        reader: {
            type: 'json'
        },
        appendId: true
    }
});
