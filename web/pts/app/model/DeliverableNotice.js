/**
 * Description: Deliverable Notice model.
 */

Ext.define('PTS.model.DeliverableNotice', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'deliverablenoticeid',
        persist: false,
        type: 'int',
        useNull: true
    }, {
        name: 'deliverableid',
        type: 'int',
        useNull: true
    }, {
        name: 'modificationid',
        type: 'int',
        useNull: true
    }, {
        name: 'noticeid',
        type: 'int',
        useNull: true
    }, {
        name: 'recipientid',
        type: 'int',
        useNull: true
    }, {
        name: 'contactid',
        type: 'int',
        useNull: true
    }, {
        name: 'datesent',
        type: 'mydate',
        useNull: true,
        defaultValue: new Date()
    }, {
        name: 'comment',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'deliverablenoticeid',
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
        field: 'noticeid',
        min: 1
    }, {
        type: 'presence',
        field: 'effectivedate'
    }],

    proxy: {
        type: 'rest',
        url: '../deliverablenotice',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
