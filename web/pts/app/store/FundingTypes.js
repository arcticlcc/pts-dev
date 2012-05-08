/*
 * File: app/store/FundingTypes.js
 * Description: Store of Funding Types
 */

Ext.define('PTS.store.FundingTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.FundingType',
    
    autoLoad: true
});
