/**
 * @class PTS.store.DeliverableNotices
 * Store of deliverable notices.
 */
Ext.define('PTS.store.DeliverableNotices', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableNotice',

    autoLoad: false,
    autoSync: false,
    sorters: [
        { property: 'datesent', direction : 'DESC' },
        { property: 'deliverablenoticeid', direction : 'DESC' }
    ],
    listeners: {
        'add': function(store, records){
            Ext.each(records, function() {
                var rec = this;

                if(null === rec.get('contactid')) {
                    rec.set('contactid', PTS.user.get('contactid'));
                }
            });
        }
    }
});
