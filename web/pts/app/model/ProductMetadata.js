/**
 * Description: productmetadata model.
 */

Ext.define('PTS.model.ProductMetadata', {
    extend : 'PTS.model.Base',
    fields : [{
        name : 'productid',
        type : 'int',
        persist : false
    }, {
        name : 'topiccategory',
        type : 'auto',
        useNull : true,
        convert : function(v) {
            return Ext.isString(v) ? v.split(',') : v;
        }
    }, {
        name : 'spatialformat',
        type : 'auto',
        useNull : true,
        convert : function(v) {
            return Ext.isString(v) ? v.split(',') : v;
        }
    }, {
        name : 'epsgcode',
        type : 'auto',
        useNull : true,
        convert : function(v) {
            return Ext.isString(v) ? v.split(',') : v;
        }
    }, {
        name : 'wkt',
        type : 'string'
    }],
    idProperty : 'productid',

    proxy : {
        type : 'rest',
        url : '../productmetadata',
        reader : {
            type : 'json',
            root : 'data'
        }
    }
});
