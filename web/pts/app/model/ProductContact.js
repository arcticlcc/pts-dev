/**
 * File: app/model/ProductContact.js
 * Description: ProductContact model.
 */

Ext.define('PTS.model.ProductContact', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'productcontactid',
        type: 'int',
        persist: false,
        useNull: true
    }, {
        name: 'contactid',
        type: 'int',
        useNull: true
    }, {
        name: 'productid',
        type: 'int',
        useNull: true
    }, {
        name: 'isoroletypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'name',
        persist: false
    }, {
        name: 'role',
        persist: false
    }],
    idProperty: 'productcontactid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/productcontact',
        appendId: true,
        //batchActions: true,
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
