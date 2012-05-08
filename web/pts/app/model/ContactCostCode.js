/**
 * File: app/model/ContactCostCode.js
 * Description: ContactCostCode model.
 */

Ext.define('PTS.model.ContactCostCode', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'costcode',
            type: 'mystring',
            persist: false,
            useNull: true
        },
        {
            name: 'contactid',
            type: 'int',
            persist: false,
            useNull: true
        }
    ],
    idProperty: 'costcode',

    proxy: {
        type: 'rest',
        url : '../contactcostcode',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
