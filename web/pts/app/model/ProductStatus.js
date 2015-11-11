/**
 * Description: Product Status model.
 */

Ext.define('PTS.model.ProductStatus', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'productstatusid',
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
        name: 'datetypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'effectivedate',
        type: 'mydate',
        useNull: true
    }, {
        name: 'comment',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'productstatusid',
    validations: [{
        type: 'length',
        field: 'productid',
        min: 1
    }, {
        type: 'length',
        field: 'datetypeid',
        min: 1
    }, {
        type: 'presence',
        field: 'effectivedate'
    }],

    proxy: {
        type: 'rest',
        url: '../productstatus',
        /*api: {
            read: '../productstatuslist'
        },*/
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
