/**
 * Modification Document model.
 */
Ext.define('PTS.model.ModDocStatus', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'moddocstatusid',
        type: 'integer',
        useNull: true,
        persist: false
    }, {
        name: 'modificationid',
        type: 'int',
        useNull: true
    }, {
        name: 'moddoctypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'moddocstatustypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'contactid',
        type: 'int',
        useNull: true
    }, {
        name: 'comment',
        type: 'mystring',
        useNull: true
    }, {
        name: 'effectivedate',
        type: 'mydate',
        useNull: true,
        defaultValue: new Date()
    }, {
        name: 'weight',
        type: 'int',
        useNull: true,
        persist: false
    }],
    idProperty: 'moddocstatusid',
    validations: [{
        type: 'length',
        field: 'moddoctypeid',
        min: 1
    }, {
        type: 'length',
        field: 'modificationid',
        min: 1
    }, {
        type: 'length',
        field: 'contactid',
        min: 1
    }],

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/moddocstatus',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
