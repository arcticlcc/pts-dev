/**
 * File: app/store/ContactGroups.js
 * Description: Store of groups
 */

Ext.define('PTS.store.ContactGroups', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ContactGroup',

    remoteSort: true,
    pageSize: PTS.Defaults.pageSize,
    sorters: { property: 'fullname', direction : 'ASC' }
});
