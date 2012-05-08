/**
 * File: app/store/ContactGroups.js
 * Description: Store of groups
 */

Ext.define('PTS.store.ContactGroups', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ContactGroup',

    pageSize: PTS.Defaults.pageSize,
    sorters: { property: 'name', direction : 'ASC' }
});
