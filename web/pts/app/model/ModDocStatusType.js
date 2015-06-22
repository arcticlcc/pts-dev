/**
 * Modification document status type model.
 */
Ext.define('PTS.model.ModDocStatusType', {
    extend: 'PTS.model.Base',
    fields: [
        {
            name: 'moddocstatustypeid',
            type: 'int',
            persist: false
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
            name: 'weight', type: 'int', useNull: true
        }
    ],
    idProperty: 'moddocstatustypeid',

    proxy: {
        type: 'ajax',
        url : '../moddocstatustype',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
