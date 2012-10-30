/**
 * Keywords store.
 */
Ext.define('PTS.store.Keywords', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.KeywordNode',

    autoLoad: true,
    remoteSort: true,
    remoteFilter: true,
    pageSize: PTS.Defaults.pageSize + 5,
    sorters: { property: 'text', direction : 'ASC' },

    proxy: {
        type: 'rest',
        url : '../keywordlist',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
