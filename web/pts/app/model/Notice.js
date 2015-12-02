/**
 * Notice model.
 */
Ext.define('PTS.model.Notice', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'noticeid',
        type: 'int',
        persist: false
    }, {
        name: 'code',
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
    }, {
        name: 'priority',
        type: 'int'
    }],
    idProperty: 'noticeid',
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/notice',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
