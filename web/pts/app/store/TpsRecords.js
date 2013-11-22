/**
 * Store of records for TPS report.
 */
Ext.define('PTS.store.TpsRecords', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.TpsRecord',

    autoLoad: false,
    //remoteSort: true,
    //remoteFilter: true,
    pageSize: PTS.Defaults.pageSize + 5,
    //sorters: { property: 'text', direction : 'ASC' },

    proxy: {
        type: 'rest',
        url : '../report/tps',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
