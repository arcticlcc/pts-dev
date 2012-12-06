/**
 * Notice model.
 */
Ext.define('PTS.model.Notice', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'noticeid',
            type: 'int',
            persist: false
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'title', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        }
    ],
    idProperty: 'noticeid',
    proxy: {
        type: 'rest',
        url : '../notice',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
