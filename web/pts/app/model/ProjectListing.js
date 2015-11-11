/**
 * Project listing(record with computed attributes) model.
 */

Ext.define('PTS.model.ProjectListing', {
    extend: 'PTS.model.Base',
    requires: [
        'PTS.util.Format'
    ],
    fields: [{
        name: 'projectid',
        type: 'int'
    }, {
        name: 'orgid',
        type: 'int'
    }, {
        name: 'parentprojectid',
        type: 'int'
    }, {
        name: 'title',
        type: 'mystring',
        useNull: true
    }, {
        name: 'shorttitle',
        type: 'mystring',
        useNull: true
    }, {
        name: 'fiscalyear',
        type: 'int'
    }, {
        name: 'number',
        type: 'int'
    }, {
        name: 'allocated',
        type: 'number'
    }, {
        name: 'invoiced',
        type: 'number'
    }, {
        name: 'difference',
        type: 'number'
    }, {
        name: 'leveraged',
        type: 'number'
    }, {
        name: 'startdate',
        type: 'mydate'
    }, {
        name: 'enddate',
        type: 'mydate'
    }, {
        name: 'description',
        type: 'mystring',
        useNull: true
    }, {
        name: 'abstract',
        type: 'mystring',
        useNull: true
    }, {
        name: 'uuid',
        type: 'mystring',
        useNull: true
    }, {
        name: 'projectcode',
        type: 'mystring',
        useNull: true
    }, {
        name: 'status',
        type: 'mystring',
        useNull: true
    }, {
        name: 'exportmetadata',
        type: 'myboolean'
    }],

    idProperty: 'projectid',

    proxy: {
        type: 'rest',
        url: '../projectlist',
        reader: {
            type: 'json',
            root: 'data'
        }
    },

    getProjectCode: function() {
        var code = this.get('projectcode');

        if (!code) {
            code = PTS.orgcode + this.get('fiscalyear') + '-' + this.get('number');
        }

        return code;
    }
});
