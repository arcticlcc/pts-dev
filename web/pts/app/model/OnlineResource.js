/**
 * OnlineResource model.
 */
Ext.define('PTS.model.OnlineResource', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'onlineresourceid',
        type: 'int',
        persist: false
    }, {
        name: 'productid',
        type: 'int'
    }, {
        name: 'onlinefunctionid',
        type: 'int'
    }, {
        name: 'uri',
        type: 'mystring',
        useNull: true
    }, {
        name: 'title',
        type: 'mystring',
        useNull: true
    }, {
        name: 'description',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'onlineresourceid',
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/onlineresource',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
