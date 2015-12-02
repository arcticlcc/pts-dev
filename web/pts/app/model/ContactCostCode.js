/**
 * File: app/model/ContactCostCode.js
 * Description: ContactCostCode model.
 */

Ext.define('PTS.model.ContactCostCode', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'costcode',
        type: 'mystring',
        persist: false,
        useNull: true
    }, {
        name: 'contactid',
        type: 'int',
        persist: false,
        useNull: true
    }],
    idProperty: 'costcode',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/contactcostcode',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
