/**
 * Purchase Request model.
 */
Ext.define('PTS.model.PurchaseRequest', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'purchaserequestid',
        type: 'integer',
        useNull: true,
        persist: false
    }, {
        name: 'purchaserequest',
        type: 'mystring',
        useNull: true
    }, {
        name: 'modificationid',
        type: 'int',
        useNull: true
    }, {
        name: 'comment',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'purchaserequestid',
    validations: [{
        type: 'length',
        field: 'purchaserequest',
        min: 1
    }, {
        type: 'length',
        field: 'modificationid',
        min: 1
    }],

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/purchaserequest',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
