/**
 * File: app/store/Countries.js
 * Description: Store of Countries
 */

Ext.define('PTS.store.Countries', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Country',

    sorters: [{
        property: 'country',
        direction: 'ASC'
    }],
    autoLoad: true
});
