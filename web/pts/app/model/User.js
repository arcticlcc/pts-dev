/**
 * File: app/model/User.js
 * Description: User model.
 */

Ext.define('PTS.model.User', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'loginid',
        mapping: 'loginid',
        type: 'int',
        persist: false
    }, {
        name: 'contactid',
        mapping: 'contactid',
        type: 'int',
        persist: false
    }, {
        name: 'groupid',
        mapping: 'groupid',
        type: 'int',
        persist: false
    }, {
        name: 'username',
        type: 'mystring',
        useNull: true
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
        name: 'groupname',
        type: 'mystring',
        useNull: true
    }, {
        name: 'acronym',
        type: 'mystring',
        useNull: true
    }, {
        name: 'groupemail',
        type: 'mystring',
        useNull: true
    }, {
        name: 'projecturiformat',
        type: 'mystring',
        useNull: true
    }, {
        name: 'config',
        type: 'auto',
        useNull: true,
        convert: function(v, rec) {
            if (v) {
                var obj = JSON.parse(v);
                obj.loginid = rec.data.loginid;
                return obj;
            } else {
                return {
                    loginid: rec.data.loginid
                };
            }
        }

    }],
    idProperty: 'loginid',

    proxy: {
        type: 'rest',
        url: '../userinfo',
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
