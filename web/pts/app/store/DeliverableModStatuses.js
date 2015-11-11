/**
 * @class PTS.store.DeliverableModStatuses
 * Store of deliverable status.
 */
Ext.define('PTS.store.DeliverableModStatuses', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableModStatus',

    autoLoad: false,
    autoSync: false,
    sorters: [{
        property: 'effectivedate',
        direction: 'DESC'
    }, {
        property: 'deliverablestatusid',
        direction: 'DESC'
    }],
    listeners: {
        'add': function(store, records) {
            Ext.each(records, function() {
                var rec = this;

                if (null === rec.get('contactid')) {
                    rec.set('contactid', PTS.user.get('contactid'));
                }
            });
        }
    }
});
