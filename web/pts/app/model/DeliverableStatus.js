/**
 * DeliverableStatus model.
 */
Ext.define('PTS.model.DeliverableStatus', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'deliverablestatusid',
        type: 'int',
        persist: false
    }, {
        name: 'code',
        type: 'mystring',
        useNull: true
    }, {
        name: 'status',
        type: 'mystring',
        useNull: true
    }, {
        name: 'description',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'deliverablestatusid',
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/deliverablestatus',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
