/**
 * Store of contact projects.
 */
Ext.define('PTS.store.ContactProjects', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectContact',

    remoteFilter: true,
    //remoteSort: true,
    autoLoad: false,

    proxy: {
        type: 'ajax',
        url: '../projectcontactfull',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
