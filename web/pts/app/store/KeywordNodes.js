/**
 * KeywordNodes store.
 */

Ext.define('PTS.store.KeywordNodes', {
    extend: 'Ext.data.TreeStore',
    model: 'PTS.model.KeywordNode',

    clearOnLoad: true,
    //folderSort: true,
    autoLoad: true
        /*,
            root: {
                children : []
            }*/
});
