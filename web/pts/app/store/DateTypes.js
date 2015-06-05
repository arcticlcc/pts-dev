/**
 * Store of DateTypes for lookups, comboboxes
 */

Ext.define('PTS.store.DateTypes', {
    extend: 'Ext.data.Store',

    fields: [
        {
            name: 'datetypeid',
            type: 'int'
        },
        {
            name: 'codename',
            type: 'string'
        },
        {
            name: 'description'
        }
    ],
    proxy: {
        type: 'rest',
        url : '../datetype',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    },
    autoLoad: true,
    sorters: [
        { property: 'codename', direction : 'ASC' }
    ]
});
