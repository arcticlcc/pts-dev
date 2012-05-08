/**
 * File: app/model/ContactGroup.js
 * Description: Contact Group model.
 */

Ext.define('PTS.model.ContactGroup', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'contactid',
            mapping: 'contactid',
            type: 'int',
            persist: false
        },
        {
            name: 'name', type: 'mystring', useNull: true
        },
        {
            name: 'acronym', type: 'mystring', useNull: true
        },
        {
            name: 'organization',
            type: 'myboolean',
            useNull: true//,
            /*convert: function(v) {
                if (this.useNull && (v === undefined || v === null || v === '' || v === false)) {
                    return null;
                }
                return (v !== 'false') && !!v;
            }*/
        },
        /*{
            name: 'orgid',
            type: 'int',
            useNull: true
        },*/
        {
            name: 'contacttypeid',
            type: 'int',
            useNull: true
        },
        {
            name: 'dunsnumber', type: 'mystring', useNull: true
        },
        {
            name: 'comment', type: 'mystring', useNull: true
        },
        {
            name: 'inactive',
            type: 'myboolean'
        }
    ],
    idProperty: 'contactid',
    hasMany: [
        {model: 'PTS.model.Address', name: 'addresses'},
        {model: 'PTS.model.Phone', name: 'phones'},
        {model: 'PTS.model.EAddress', name: 'eaddresses'}
    ],

    proxy: {
        type: 'rest',
        url : '../contactgroup',
        reader: {
            type: 'json',
            root: 'data'
        },
        writer: {
            type: 'ajson'
        }
    },

    getContactName: function() {
        return this.get('name');
    },

    getContactType: function() {
        return 'group';
    }
});
