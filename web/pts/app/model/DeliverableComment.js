/**
 * Deliverable Comment model.
 */
Ext.define('PTS.model.DeliverableComment', {
    extend: 'PTS.model.Base',
    fields: [
        {
            name: 'deliverablecommentid',
            type: 'integer',
            useNull: true,
            persist: false
        },
        {
            name: 'deliverableid',
            type: 'int',
            useNull: true
        },
        {
            name: 'contactid',
            type: 'int',
            useNull: true
        },
        {
            name: 'comment',
            type: 'mystring',
            useNull: true
        },
        {
            name: 'datemodified',
            type: 'mydate',
            useNull: true,
            defaultValue: new Date()
        }
    ],
    idProperty: 'deliverablecommentid',
    validations: [{
        type: 'length',
        field: 'comment',
        min: 1
    }, {
        type: 'length',
        field: 'deliverableid',
        min: 1
    }, {
        type: 'length',
        field: 'contactid',
        min: 1
    }],

    proxy: {
        type: 'rest',
        url : '../deliverablecomment',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
