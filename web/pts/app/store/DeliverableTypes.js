/*
 * File: app/store/DeliverableTypes.js
 * Description: Store of Deliverable Types
 */
//TODO: create separate store for tasks
Ext.define('PTS.store.DeliverableTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableType',

    autoLoad: true
});
