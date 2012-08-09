/**
 * Store of contactgroup ids for lookups, comboboxes
 */

Ext.define('PTS.store.ContactGroupIDs',{
    extend: 'Ext.data.Store',
    model: 'PTS.model.ContactGroupID',

    remoteSort: true,
    autoLoad: true,
    //pageSize: PTS.Defaults.pageSize,
    sorters: { property: 'fullname', direction : 'ASC' },
    proxy: {
        type: 'ajax',
        url : '../contactgrouplist',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
