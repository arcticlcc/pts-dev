/**
 *@class PTS.util.mixin.FixRemoteQuery
 *A mixin that updates a query event to be compatible with the PTS API
 */
Ext.define('PTS.util.mixin.FixRemoteQuery', {

    /**
     * Check the container for dirty fields
     * @return {String}
     */
    fixRemoteQuery: function(queryEvent) {
        var filter = '[{"property":"' + queryEvent.combo.displayField + '","value":["ilike","' + queryEvent.query + '"]}]';

        queryEvent.query = filter;

    }
});
