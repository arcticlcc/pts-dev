/**
 * File: app/model/Address.js
 * Description: Address model.
 */

Ext.define('PTS.model.Address', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'addressid',
        type: 'int',
        useNull: true
    }, {
        name: 'contactid',
        type: 'int',
        useNull: true
    }, {
        name: 'addresstypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'street1',
        type: 'mystring',
        useNull: true
    }, {
        name: 'street2',
        type: 'mystring',
        useNull: true
    }, {
        name: 'city',
        type: 'mystring',
        useNull: true
    }, {
        name: 'postalcode',
        type: 'mystring',
        useNull: true
    }, {
        name: 'postal4',
        type: 'int',
        useNull: true
    }, {
        name: 'stateid',
        type: 'int',
        useNull: true
    }, {
        name: 'countyid',
        type: 'int',
        useNull: true
    }, {
        name: 'countryiso',
        type: 'mystring',
        useNull: true
    }, {
        name: 'comment',
        type: 'mystring',
        useNull: true
    }, {
        name: 'priority',
        type: 'int',
        useNull: true,
        defaultValue: 1
    }],
    idProperty: 'addressid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/address',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
