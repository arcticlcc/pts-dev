/**
 * File: app/model/User.js
 * Description: User model.
 */

Ext.define('PTS.model.User', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'loginid',
            mapping: 'loginid',
            type: 'int',
            persist: false
        },
        {
            name: 'contactid',
            mapping: 'contactid',
            type: 'int',
            persist: false
        },
        {
            name: 'groupid',
            mapping: 'groupid',
            type: 'int',
            persist: false
        },
        {
            name: 'username', type: 'mystring', useNull: true
        },
        {
            name: 'firstname', type: 'mystring', useNull: true
        },
        {
            name: 'lastname', type: 'mystring', useNull: true
        },
        {
            name: 'middlename', type: 'mystring', useNull: true
        },
        {
            name: 'suffix', type: 'mystring', useNull: true
        },
        {
            name: 'groupname', type: 'mystring', useNull: true
        },
        {
            name: 'acronym', type: 'mystring', useNull: true
        }
    ],
    idProperty: 'loginid',

    proxy: {
        type: 'rest',
        url : '../userinfo',
        reader: {
            type: 'json',
            root: 'data'
        }
    },

    getUserName: function() {
        var first = this.get('firstname'),
            last = this.get('lastname');

        return last + ', ' + first;
    }
});
