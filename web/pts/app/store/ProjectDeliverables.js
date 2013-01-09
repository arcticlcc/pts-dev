/**
 * ProjectDeliverables store.
 */

Ext.define('PTS.store.ProjectDeliverables', {
    extend: 'PTS.store.DeliverableListings',
    model: 'PTS.model.DeliverableListing',

    autoLoad: false,
    filters: []
});
