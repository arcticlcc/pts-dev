/**
 * File: app/model/ContactType.js
 * Description: ContactType model.
 */

Ext.define('PTS.model.ContactType', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'contacttypeid',
            type: 'int',
            persist: false
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'title', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'contacttypeid',

    proxy: {
        type: 'rest',
        url : '../contacttype',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
