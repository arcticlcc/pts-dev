/**
 * Description: Product Step model.
 */

Ext.define('PTS.model.ProductStep', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'productstepid',
        persist: false,
        type: 'int',
        useNull: true
    }, {
        name: 'productid',
        type: 'int',
        useNull: true
    }, {
        name: 'contactid',
        type: 'int',
        useNull: true
    }, {
        name: 'priority',
        type: 'int',
        useNull: true
    }, {
        name: 'stepdate',
        type: 'mydate',
        useNull: true
    }, {
        name: 'description',
        type: 'mystring',
        useNull: true
    }, {
        name: 'rationale',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'productstepid',
    validations: [{
        type: 'length',
        field: 'productid',
        min: 1
    }, {
        type: 'length',
        field: 'description',
        min: 1
    }, {
        type: 'presence',
        field: 'stepdate'
    }],

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/productstep',
        /*api: {
            read: PTS.baseURL + '/productstatuslist'
        },*/
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
