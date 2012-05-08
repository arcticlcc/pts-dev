/**
 * File: app/model/Phone.js
 * Description: Phone model.
 */

Ext.define('PTS.model.Phone', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'phoneid',
            type: 'int',
            useNull: true
        },
        {
            name: 'contactid',
            type: 'int',
            useNull: true
        },
        {
            name: 'phonetypeid',
            type: 'int',
            useNull: true
        },
        {
            name: 'areacode',
            type: 'int',
            useNull: true
        },
        {
            name: 'phnumber',
            type: 'int',
            useNull: true
        },
        {
            name: 'extension',
            type: 'int',
            useNull: true
        },
        {
            name: 'countryiso', type: 'mystring', useNull: true
        },
        {
            name: 'priority',
            type: 'int',
            useNull: true,
            defaultValue: 1
        }
    ],
    idProperty: 'phoneid',

    proxy: {
        type: 'rest',
        url : '../phone',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
