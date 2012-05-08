/**
 * File: app/model/RoleType.js
 * Description: RoleType model.
 */

Ext.define('PTS.model.RoleType', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'roletypeid',
            type: 'int',
            persist: false
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'roletype', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'roletypeid',

    proxy: {
        type: 'rest',
        url : '../roletype',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
