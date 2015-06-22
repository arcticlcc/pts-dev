/**
 * Description: projectmetadata model.
 */

Ext.define('PTS.model.ProjectMetadata', {
    extend : 'PTS.model.Base',
    fields : [{
        name : 'projectid',
        type : 'int',
        persist : false
    }, {
        name : 'projectcategory',
        type : 'auto',
        useNull : true,
        convert : function(v) {
            return Ext.isString(v) ? v.split(',') : v;
        }
    }, {
        name : 'usertype',
        type : 'auto',
        useNull : true,
        convert : function(v) {
            return Ext.isString(v) ? v.split(',') : v;
        }
    }, {
        name : 'topiccategory',
        type : 'mystring',
        useNull : true,
        convert : function(v) {
            return Ext.isString(v) ? v.split(',') : v;
        }
    }],
    idProperty : 'projectid',

    proxy : {
        type : 'rest',
        url : '../projectmetadata',
        reader : {
            type : 'json',
            root : 'data'
        }
    }
});
