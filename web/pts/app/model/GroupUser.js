/**
 * File: app/model/GroupUser.js
 * Description: GroupUser model. Returns user info
 * for the current PTS.user group.
 */

Ext.define('PTS.model.GroupUser', {
    extend: 'Ext.data.Model',
    fields: [
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
        },
        {
            name: 'fullname',
            convert: function(v, record) {
                return record.data.lastname + ', ' + record.data.firstname;
            }

        }

    ],
    idProperty: 'contactid',

    //need to set proxy at runtime due to dynamic url
    /*proxy: {
        type: 'ajax',
        url : '../contactgroup/' + PTS.user.get('groupid') + '/person',
        reader: {
            type: 'json',
            root: 'data'
        }
    },*/

    getUserName: function() {
        var first = this.get('firstname'),
            last = this.get('lastname');

        return last + ', ' + first;
    }
});
