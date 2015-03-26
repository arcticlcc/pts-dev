/**
 * Status model.
 */
Ext.define('PTS.model.Status', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'statusid',
            type: 'int'
        },
        {
            name: 'modtypeid',
            type: 'int'
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'status', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        },
        {
            name: 'weight',
            type: 'int'
        }
    ],
    //idProperty: 'statusid',

    proxy: {
        type: 'rest',
        url : '../statuslist',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
