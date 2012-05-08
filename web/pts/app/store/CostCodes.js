/**
 * Store of funding costcodes.
 */
Ext.define('PTS.store.CostCodes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.CostCode',

    autoLoad: false,
    autoSync: false
});
