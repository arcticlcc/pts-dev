/**
 * Store of IsoRoleTypes for lookups, comboboxes
 */

Ext.define('PTS.store.IsoRoleTypes', {
    extend: 'Ext.data.Store',

    fields: [{
        name: 'isoroletypeid',
        type: 'int'
    }, {
        name: 'codename',
        type: 'string'
    }, {
        name: 'description'
    }],
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/isoroletype',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    },
    autoLoad: true,
    sorters: [{
        property: 'codename',
        direction: 'ASC'
    }]
});
