/**
 * Store of contact costcodes.
 * TODO: make this relative to current user
 */
Ext.define('PTS.store.ContactCostCodes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ContactCostCode',

    autoLoad: true
});
