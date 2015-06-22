/**
 * Project Comment model.
 */
Ext.define('PTS.model.ProjectComment', {
    extend: 'PTS.model.Base',
    fields: [
        {
            name: 'projectcommentid',
            type: 'integer',
            useNull: true,
            persist: false
        },
        {
            name: 'projectid',
            type: 'int',
            useNull: true
        },
        {
            name: 'contactid',
            type: 'int',
            useNull: true
        },
        {
            name: 'comment',
            type: 'mystring',
            useNull: true
        },
        {
            name: 'publish',
            type: 'myboolean',
            useNull: true,
            defaultValue: false
        },
        {
            name: 'datemodified',
            type: 'mydate',
            useNull: true,
            defaultValue: new Date()
        }
    ],
    idProperty: 'projectcommentid',
    validations: [{
        type: 'length',
        field: 'comment',
        min: 1
    }, {
        type: 'length',
        field: 'projectid',
        min: 1
    }, {
        type: 'length',
        field: 'contactid',
        min: 1
    }],

    proxy: {
        type: 'rest',
        url : '../projectcomment',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
