/**
 * File: app/model/AgreementsTree.js
 * Description: AgreementsTree model.
 */

Ext.define('PTS.model.AgreementsTree', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'dataid',
            type: 'string'
        }, {
            name: 'fkey',
            type: 'auto'
        }, {
            name: 'typeid',
            type: 'int'
        }, {
            name: 'text',
            type: 'mystring',
            useNull: true
        }, {
            name: 'code',
            type: 'mystring',
            useNull: true
        }, {
            name: 'parentcode',
            type: 'mystring',
            useNull: true
        }, {
            name: 'type',
            type: 'mystring',
            useNull: true
        }, {
            name: 'status',
            type: 'mystring',
            useNull: true
        }, {
            name: 'invalid',
            type: 'boolean'
        }, {
            name: 'hilite',
            type: 'boolean'
        }, {
            name: 'readonly',
            type: 'boolean',
            defaultValue: false
        }, {
            name: 'defIcon',
            type: 'mystring',
            useNull: true
        }, {
            name: 'parentItm',
            type: 'mystring',
            useNull: true
        }

    ],
    idProperty: 'id',

    proxy: {
        type: 'memory'
    }
});
