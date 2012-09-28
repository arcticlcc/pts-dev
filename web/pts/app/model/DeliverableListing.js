/**
 * DeliverableListing model.
 */

Ext.define('PTS.model.DeliverableListing', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'deliverableid',
            persist: false,
            type: 'int',
            useNull: true
        },
        {
            name: 'modificationid',
            type: 'int',
            useNull: true
        },
        {
            name: 'projectid',
            type: 'int',
            useNull: true
        },
        {name: 'duedate', type: 'mydate'},
        {name: 'receiveddate', type: 'mydate'},
        {name: 'title', type: 'mystring', useNull: true},
//        {name: 'description', type: 'mystring', useNull: true},
        {name: 'projectcode', type: 'mystring', useNull: true},
        {name: 'project', type: 'mystring', useNull: true},
        {name: 'contact', type: 'mystring', useNull: true},
        {name: 'email', type: 'mystring', useNull: true},
        {name: 'dayspastdue', type: 'int', useNull: true},
        {name: 'completed', type: 'mybool', useNull: true},
        {name: 'status', type: 'mystring', useNull: true}
    ],
    idProperty: 'deliverableid',

    proxy: {
        type: 'rest',
        url : '../deliverabledue',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
