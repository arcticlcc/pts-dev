/**
 * Store of UserTypes.
 */

Ext.define('PTS.store.UserTypes', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.UserType',

    autoLoad: true,
    sorters: [{
        property: 'usertype',
        direction: 'ASC'
    }]
});
