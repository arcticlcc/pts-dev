/**
 * Funding Comment model.
 */
Ext.define('PTS.model.FundingComment', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'fundingcommentid',
        type: 'integer',
        useNull: true,
        persist: false
    }, {
        name: 'fundingid',
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
        name: 'datemodified',
        type: 'mydate',
        useNull: true,
        defaultValue: new Date()
    }],
    idProperty: 'fundingcommentid',
    validations: [{
        type: 'length',
        field: 'comment',
        min: 1
    }, {
        type: 'length',
        field: 'fundingid',
        min: 1
    }, {
        type: 'length',
        field: 'contactid',
        min: 1
    }],

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/fundingcomment',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
