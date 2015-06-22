/**
 * Project model.
 */

Ext.define('PTS.model.Project', {
    extend: 'PTS.model.Base',
    requires: [
        'PTS.util.Format'
    ],
    fields: [
        {
            name: 'projectid',
            type: 'int',
            persist: false
        },
        {
            name: 'orgid',
            type: 'int',
            //defaultValue: PTS.user.get('groupid'), //TODO: remove when orgid tracking is implemented
            useNull: true,
            convert: function(v, record) {
                return v ? v : PTS.user.get('groupid');
            }
        },
        {
            name: 'parentprojectid',
            type: 'int',
            useNull: true
        },
        {
            name: 'title', type: 'mystring', useNull: true
        },
        {
            name: 'shorttitle', type: 'mystring', useNull: true
        },
        {
            name: 'fiscalyear',
            type: 'int',
            useNull: true
        },
        {
            name: 'number',
            type: 'int',
            useNull: true
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
            name: 'supplemental', type: 'mystring', useNull: true
        },
        {
            name: 'uuid',
            persist: false
        },
        {
            name: 'exportmetadata',
            type: 'myboolean'
        },
        {
            name: 'projectcode',
            persist: false,
            convert: function(v, record) {
                return PTS.orgcode + PTS.util.Format.projectCode(record.data.fiscalyear,record.data.number);
            }
        }
    ],

    idProperty: 'projectid',

    proxy: {
        type: 'rest',
        url : '../project',
        reader: {
            type: 'json',
            root: 'data'
        }
    },

    getProjectCode: function() {
        var fy = this.get('fiscalyear'),
            num = this.get('number');

        return fy + '-' + num;
    }
});
