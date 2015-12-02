/**
 * Modification documents.
 */

Ext.define('PTS.model.ModDocType', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'moddoctypeid',
        type: 'int',
        persist: false
    }, {
        name: 'type',
        type: 'mystring',
        useNull: true
    }, {
        name: 'code',
        type: 'mystring',
        useNull: true
    }, {
        name: 'description',
        type: 'mystring',
        useNull: true
    }, {
        name: 'inactive',
        type: 'myboolean'
    }],
    idProperty: 'moddoctypeid',
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/moddoctype',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
