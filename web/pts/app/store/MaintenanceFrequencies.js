/**
 * Store of maintenanceFrequency codes
 */

Ext.define('PTS.store.MaintenanceFrequencies', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.MaintenanceFrequency',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/maintenancefrequency',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    },
    autoLoad: true,
    sorters: [{
        property: 'code',
        direction: 'ASC'
    }]
});
