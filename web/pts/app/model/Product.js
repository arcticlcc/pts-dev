/**
 * Product model.
 */

Ext.define('PTS.model.Product', {
    extend: 'PTS.model.Base',

    fields: [{
        name: 'productid',
        type: 'int',
        persist: false
    }, {
        name: 'projectid',
        type: 'int',
        useNull: true
    }, {
        name: 'productgroupid',
        type: 'int',
        useNull: true
    }, {
        name: 'deliverabletypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'isoprogresstypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'maintenancefrequencyid',
        type: 'int',
        useNull: true
    }, {
        name: 'title',
        type: 'mystring',
        useNull: true
    }, {
        name: 'startdate',
        type: 'mydate'
    }, {
        name: 'enddate',
        type: 'mydate'
    }, {
        name: 'perioddescription',
        type: 'mystring',
        useNull: true
    }, {
        name: 'description',
        type: 'mystring',
        useNull: true
    }, {
        name: 'abstract',
        type: 'mystring',
        useNull: true
    }, {
        name: 'purpose',
        type: 'mystring',
        useNull: true
    }, {
        name: 'uuid',
        persist: false
    }, {
        name: 'exportmetadata',
        type: 'myboolean'
    }, {
        name: 'projectcode',
        type: 'string',
        persist: false,
        convert: function(v, record) {
            return v ? v : 'None';
        }
    }, {
        name: 'type',
        type: 'string',
        persist: false
    }, {
        name: 'uselimitation',
        type: 'mystring',
        useNull: true
    }, {
        name: 'isgroup',
        type: 'myboolean',
        useNull: true
    }, {
        name: 'productgroup',
        type: 'string',
        persist: false,
        convert: function(v, record) {
            return v ? v : 'None';
        }
    }],

    idProperty: 'productid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/product',
        api: {
            read: PTS.baseURL + '/productlist' //,uri,
                //create: uri,
                //update: uri
        },
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
