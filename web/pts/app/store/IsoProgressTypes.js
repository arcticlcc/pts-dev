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
        },
        {
            name: 'product',
            type: 'myboolean'
        }
    ],
    proxy: {
        type: 'rest',
        url : '../productprogresstype',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    },
    autoLoad: true,
    sorters: [
        { property: 'codename', direction : 'ASC' }
    ]/*,
    filters: [
        {
            property: 'product',
            value   : true
        }
    ]*/
});
