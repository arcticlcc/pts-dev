/**
 * Store of IsoProgressTypes for lookups, comboboxes
 */

Ext.define('PTS.store.IsoProgressTypes', {
    extend: 'Ext.data.Store',

    fields: [
        {
            name: 'isoprogresstypeid',
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
        url : '../isoprogresstype',
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
