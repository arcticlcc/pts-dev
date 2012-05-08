/**
 * File: app/model/ProjectListing.js
 * Description: Project listing(record with computed attributes) model.
 */

Ext.define('PTS.model.ProjectListing', {
    extend: 'Ext.data.Model',
    requires: [
        'PTS.util.Format'
    ],
    fields: [
        {
            name: 'projectid',
            type: 'int'
        },
        {
            name: 'orgid',
            type: 'int'
        },
        {
            name: 'parentprojectid',
            type: 'int'
        },
        {
            name: 'title', type: 'mystring', useNull: true
        },
        {
            name: 'fiscalyear',
            type: 'int'
        },
        {
            name: 'number',
            type: 'int'
        },
        {
            name: 'allocated',
            type: 'int'
        },
        {
            name: 'invoiced',
            type: 'int'
        },
        {
            name: 'difference',
            type: 'int'
        },
        {
            name: 'startdate',
            type: 'mydate'
        },
        {
            name: 'enddate',
            type: 'mydate'
        },
        {
            name: 'description', type: 'mystring', useNull: true
        },
        {
            name: 'abstract', type: 'mystring', useNull: true
        },
        {
            name: 'uuid', type: 'mystring', useNull: true
        },
        {
            name: 'projectcode', type: 'mystring', useNull: true
        }
    ],

    idProperty: 'projectid',

    proxy: {
        type: 'rest',
        url : '../projectlist',
        reader: {
            type: 'json',
            root: 'data'
        }
    },

    getProjectCode: function() {
        var code = this.get('projectcode');

        if(!code) {
            code = PTS.orgcode + this.get('fiscalyear') + '-' + this.get('number');
        }

        return code;
    }
});
