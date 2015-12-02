/**
 * Modification Comment model.
 */
Ext.define('PTS.model.ModificationComment', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'modcommentid',
        type: 'integer',
        useNull: true,
        persist: false
    }, {
        name: 'modificationid',
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
        name: 'publish',
        type: 'myboolean',
        useNull: true,
        defaultValue: false
    }, {
        name: 'datemodified',
        type: 'mydate',
        useNull: true,
        defaultValue: new Date()
    }],
    idProperty: 'modcommentid',
    validations: [{
        type: 'length',
        field: 'comment',
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
        url: PTS.baseURL + '/modcomment',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
