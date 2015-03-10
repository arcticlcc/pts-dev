/**
 * Modification documents.
 */

Ext.define('PTS.model.ModDocType', {
    extend: 'Ext.data.Model',
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
        url: '../moddoctype',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
