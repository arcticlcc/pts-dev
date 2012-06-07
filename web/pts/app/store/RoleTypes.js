/**
 * File: app/store/RoleTypes.js
 * Description: Store of Role Types
 */

Ext.define('PTS.store.RoleTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.RoleType',

    autoLoad: true,
    sorters: [
        'code'
    ]
});
