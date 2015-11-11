/**
 * File: app/model/Person.js
 * Description: Person model.
 */

Ext.define('PTS.model.Person', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'contactid',
            mapping: 'contactid',
            type: 'int',
            persist: false
        }, {
            name: 'firstname',
            type: 'mystring',
            useNull: true
        }, {
            name: 'lastname',
            type: 'mystring',
            useNull: true
        }, {
            name: 'middlename',
            type: 'mystring',
            useNull: true
        }, {
            name: 'suffix',
            type: 'mystring',
            useNull: true
        }, {
            name: 'positionid',
            type: 'int',
            useNull: true
        }, {
            name: 'contacttypeid',
            type: 'int',
            useNull: true
        }, {
            name: 'dunsnumber',
            type: 'mystring'
        }, {
            name: 'comment',
            type: 'mystring'
        }, {
            name: 'inactive',
            type: 'myboolean'
        },
        //extra data, not persisted
        {
            name: 'prigroupid',
            type: 'int',
            persist: false
        }, {
            name: 'priacronym',
            type: 'mystring',
            persist: false,
            useNull: true
        }, {
            name: 'prigroupname',
            type: 'mystring',
            persist: false,
            useNull: true
        }, {
            name: 'priareacode',
            type: 'int',
            persist: false,
            useNull: true
        }, {
            name: 'priphnumber',
            type: 'int',
            persist: false,
            useNull: true
        }, {
            name: 'priextension',
            type: 'int',
            persist: false,
            useNull: true
        }, {
            name: 'pricountryiso',
            type: 'mystring',
            persist: false,
            useNull: true
        }, {
            name: 'priemail',
            type: 'mystring',
            persist: false,
            useNull: true
        }

    ],
    idProperty: 'contactid',
    hasMany: [{
        model: 'PTS.model.Address',
        name: 'addresses'
    }, {
        model: 'PTS.model.Phone',
        name: 'phones'
    }, {
        model: 'PTS.model.EAddress',
        name: 'eaddresses'
    }],

    proxy: {
        type: 'rest',
        url: '../person',
        /*api: {
            read:'../personlist'
        },*/
        reader: {
            type: 'json',
            root: 'data'
        },
        writer: {
            type: 'ajson'
        }
    },

    getContactName: function() {
        var first = this.get('firstname'),
            last = this.get('lastname');

        return last + ', ' + first;
    },
    getContactType: function() {
        return 'person';
    }
});
