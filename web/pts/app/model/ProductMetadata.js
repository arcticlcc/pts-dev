/**
 * Description: productmetadata model.
 */

Ext.define('PTS.model.ProductMetadata', {
    extend : 'Ext.data.Model',
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
