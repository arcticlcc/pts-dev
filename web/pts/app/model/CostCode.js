/**
 * File: app/model/CostCode.js
 * Description: CostCode model.
 */

Ext.define('PTS.model.CostCode', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'costcodeid',
            type: 'int',
            persist: false
        }, {
            name: 'fundingid',
            type: 'int',
            persist: true
        }, {
            name: 'costcode',
            type: 'mystring',
            useNull: true
        }, {
            name: 'startdate',
            type: 'mydate',
            useNull: true
        }, {
            name: 'enddate',
            type: 'mydate',
            useNull: true
        }

    ],
    idProperty: 'costcodeid',

    validations: [{
        type: 'length',
        field: 'costcodeid',
        min: 1
    }, {
        type: 'length',
        field: 'fundingid',
        min: 1
    }, {
        type: 'presence',
        field: 'costcode'
    }, {
        type: 'presence',
        field: 'startdate'
    }, {
        type: 'presence',
        field: 'enddate'
    }],

    proxy: {
        type: 'rest',
        url: '../costcode',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
