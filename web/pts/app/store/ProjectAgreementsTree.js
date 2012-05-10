/**
 * File: app/store/ProjectAgreementsTree.js
 * Description: ProjectAgreementsTree store.
 */
Ext.define('PTS.store.ProjectAgreementsTree', {
    extend: 'Ext.data.TreeStore',
    model: 'PTS.model.AgreementsTree',

    clearOnLoad: true,
    folderSort: false,
    autoLoad: false,
    root: {
        children : []
    }
    //sorters: { property: 'lastname', direction : 'ASC' }
});
