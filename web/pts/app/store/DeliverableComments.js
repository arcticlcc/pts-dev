/**
 * DeliverableComments store.
 */

Ext.define('PTS.store.DeliverableComments', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.DeliverableComment',

    autoLoad: false //,
        //remoteSort: true,
        //remoteFilter: true,
        //pageSize: PTS.Defaults.pageSize
        /*listeners: {
            add: {
                fn: function(store, records){
                    Ext.each(records, function() {
                        var rec = this;

                        if(null === rec.get('contactid')) {
                            rec.set('contactid', PTS.user.get('contactid'));
                        }
                    });
                }
            }
        }*/
});
