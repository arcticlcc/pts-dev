/**
 * PersonGroup model.
 * A person contact instance and assigned group.
 */

Ext.define('PTS.model.PersonGroup', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'contactid',
        type: 'int',
        persist: false
    }, {
        name: 'groupid',
        type: 'int',
        persist: false
    }, {
        name: 'positionid',
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
        name: 'groupfullname',
        type: 'mystring',
        useNull: true
    }, {
        name: 'groupname',
        type: 'mystring',
        useNull: true
    }, {
        name: 'acronym',
        type: 'mystring',
        useNull: true
    }, {
        name: 'position',
        type: 'mystring',
        useNull: true
    }, {
        name: 'fullname',
        convert: function(v, record) {
            return record.data.lastname + ', ' + record.data.firstname;
        }

    }],

    proxy: {
        type: 'ajax',
        url: PTS.baseURL + '/grouppersonfull',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
