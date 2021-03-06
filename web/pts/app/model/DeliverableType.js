/**
 * File: app/model/DeliverableType.js
 * Description: DeliverableType model.
 */

Ext.define('PTS.model.DeliverableType', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'deliverabletypeid',
            type: 'int',
            persist: false
        }, {
            name: 'code',
            type: 'mystring',
            useNull: true
        }, {
            name: 'type',
            type: 'mystring',
            useNull: true
        }, {
            name: 'description',
            type: 'mystring',
            useNull: true
        }, {
            name: 'isocodename',
            type: 'mystring',
            useNull: true
        }, {
            name: 'product',
            type: 'myboolean',
            useNull: true
        }

    ],
    idProperty: 'deliverabletypeid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/deliverabletype',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
