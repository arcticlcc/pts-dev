/*
 * File: app/store/AgreementsTree.js
 * Description: AgreementsTree store.
 */

Ext.define('PTS.store.AgreementsTree', {
    extend: 'Ext.data.TreeStore',
    model: 'PTS.model.AgreementsTree',
    
    clearOnLoad: false,
    folderSort: true,
    autoLoad: false,
    root: {
        children : []
    }
});
