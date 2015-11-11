/**
 * ReportTree store. Contains a list of available reports,
 * organized by category.
 */
Ext.define('PTS.store.ReportTree', {
    extend: 'Ext.data.TreeStore',
    model: 'PTS.model.ReportTree',

    clearOnLoad: true,
    folderSort: true,
    autoLoad: true,

    proxy: {
        type: 'ajax',
        url: '../report/tree',
        reader: {
            type: 'json'
        }
    }
    //sorters: { property: 'lastname', direction : 'ASC' }
});
