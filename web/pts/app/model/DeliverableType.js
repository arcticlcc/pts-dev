/**
 * File: app/model/DeliverableType.js
 * Description: DeliverableType model.
 */

Ext.define('PTS.model.DeliverableType', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'deliverabletypeid',
            type: 'int',
            persist: false
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'type', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'deliverabletypeid',

    proxy: {
        type: 'rest',
        url : '../deliverabletype',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
