/**
 * Description: Deliverable Status model.
 */

Ext.define('PTS.model.DeliverableModStatus', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'deliverablemodstatusid',
            persist: false,
            type: 'int',
            useNull: true
        },
        {
            name: 'deliverableid',
            type: 'int',
            useNull: true
        },
        {
            name: 'modificationid',
            type: 'int',
            useNull: true
        },
        {
            name: 'deliverablestatusid',
            type: 'int',
            useNull: true
        },
        {
            name: 'contactid',
            type: 'int',
            useNull: true
        },
        {
            name: 'effectivedate',
            type: 'mydate',
            useNull: true,
            defaultValue: new Date()
        },
        {
            name: 'comment',
            type: 'mystring',
            useNull: true
        }
    ],
    idProperty: 'deliverablemodstatusid',
    validations: [{
        type: 'length',
        field: 'modificationid',
        min: 1
    }, {
        type: 'length',
        field: 'deliverableid',
        min: 1
    }, {
        type: 'length',
        field: 'deliverablestatusid',
        min: 1
    }, {
        type: 'presence',
        field: 'effectivedate'
    }],

    proxy: {
        type: 'rest',
        url : '../deliverablemodstatus',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
