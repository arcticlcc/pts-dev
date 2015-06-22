/**
 * File: app/model/EAddress.js
 * Description: Electronic Address model.
 */

Ext.define('PTS.model.EAddress', {
    extend: 'PTS.model.Base',
    fields: [
        {
            name: 'eaddressid',
            type: 'int',
            useNull: true
        },
        {
            name: 'contactid',
            type: 'int',
            useNull: true
        },
        {
            name: 'eaddresstypeid',
            type: 'int',
            useNull: true
        },
        {
            name: 'uri', type: 'mystring', useNull: true
        },
        {
            name: 'priority',
            type: 'int',
            useNull: true,
            defaultValue: 1
        }
    ],
    idProperty: 'eaddressid',
    /*belongsTo: [
        {model: 'PTS.model.Person', getterName: 'getPerson', setterName: 'setPerson', foreignKey: 'contactid', primaryKey: 'contactid'},
        {model: 'PTS.model.ContactGroup', getterName: 'getContactGroup', setterName: 'setContactGroup', foreignKey: 'contactid'}
    ],*/

    proxy: {
        type: 'rest',
        url : '../eaddress',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
