/**
 * @class PTS.store.OnlineResources
 * Store of online resources.
 */
Ext.define('PTS.store.OnlineResources', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.OnlineResource',

    autoLoad: false,
    sorters: [{
        property: 'onlineresourceid',
        direction: 'ASC'
    }]
});
