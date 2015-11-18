/**
 * File: app/model/ProjectContact.js
 * Description: ProjectContact model.
 */

Ext.define('PTS.model.ProjectContact', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'projectcontactid',
        type: 'int',
        persist: false,
        useNull: true
    }, {
        name: 'contactid',
        type: 'int',
        useNull: true
    }, {
        name: 'projectid',
        type: 'int',
        useNull: true
    }, {
        name: 'roletypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'priority',
        type: 'int',
        useNull: true
    }, {
        name: 'name',
        persist: false
    }, {
        name: 'role',
        persist: false
    }, {
        name: 'type',
        persist: false
    }, {
        name: 'contactprojectcode'
    }, {
        name: 'partner',
        type: 'boolean',
        'default': false,
        useNull: true,
        convert: function(v) {
            if (this.useNull && (v === undefined || v === null || v === '')) {
                return null;
            }
            return (v !== 'false') && !!v;
        }
    }, {
        name: 'projectcode',
        type: 'mystring',
        persist: false
    }, {
        name: 'shorttitle',
        type: 'mystring',
        persist: false
    }, {
        name: 'reminder',
        type: 'boolean',
        defaultValue: false,
        useNull: true
    }, {
        name: 'namerole',
        persist: false,
        convert: function(v, record) {
            return record.data.name + ': ' + record.data.role;
        }
    }],
    idProperty: 'projectcontactid',

    proxy: {
        type: 'rest',
        url: '../projectcontact',
        appendId: true,
        //batchActions: true,
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
