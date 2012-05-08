/**
 * File: app/model/ModStatus.js
 * Description: Modification Status model.
 */

Ext.define('PTS.model.ModStatus', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'modstatusid',
            persist: false,
            type: 'int',
            useNull: true
        },
        {
            name: 'modificationid',
            type: 'int',
            useNull: true
        },
        {
            name: 'statusid',
            type: 'int',
            useNull: true
        },
        {
            name: 'effectivedate',
            type: 'mydate',
            useNull: true
        },
        {
            name: 'comment',
            type: 'mystring',
            useNull: true
        }
    ],
    idProperty: 'modstatusid',
    validations: [{
        type: 'length',
        field: 'modificationid',
        min: 1
    }, {
        type: 'length',
        field: 'statusid',
        min: 1
    }, {
        type: 'presence',
        field: 'effectivedate'
    }],

    proxy: {
        type: 'rest',
        url : '../modstatus',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
