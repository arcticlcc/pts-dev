/**
 * FundingComments store.
 */

Ext.define('PTS.store.FundingComments', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.FundingComment',

    autoLoad: false//,
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
