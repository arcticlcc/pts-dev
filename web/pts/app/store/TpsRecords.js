/**
 * Store of records for TPS report.
 */
Ext.define('PTS.store.TpsRecords', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.TpsRecord',

    autoLoad: false,
    remoteSort: true,
    remoteFilter: true,
    pageSize: PTS.Defaults.pageSize + 5,
    filters: [{
            property: 'weight',
            value: ['<', 40]
        }]
        //sorters: { property: 'text', direction : 'ASC' }
});
