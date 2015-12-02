/**
 * File: app/model/Country.js
 * Description: Govunit Country model.
 */

Ext.define('PTS.model.Country', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'countryid',
        mapping: 'countryiso',
        type: 'mystring',
        useNull: true
    }, {
        name: 'iso3',
        type: 'mystring',
        useNull: true
    }, {
        name: 'isonumeric',
        type: 'mystring',
        useNull: true
    }, {
        name: 'fips',
        type: 'mystring',
        useNull: true
    }, {
        name: 'country',
        type: 'mystring',
        useNull: true
    }, {
        name: 'currencycode',
        type: 'mystring',
        useNull: true
    }, {
        name: 'currencyname',
        type: 'mystring',
        useNull: true
    }, {
        name: 'phone',
        type: 'mystring',
        useNull: true
    }, {
        name: 'postalcodeformat',
        type: 'mystring',
        useNull: true
    }, {
        name: 'postalcoderegex',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'countryid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/country',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
