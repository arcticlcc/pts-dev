/**
 * Task model.
 */

Ext.define('PTS.model.Task', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'deliverableid',
            type: 'int'
        },
        {
            name: 'contactid',
            type: 'int'
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
        {
            name: 'title', type: 'mystring', useNull: true
        },
        {
            name: 'duedate',
            type: 'mydate'
        },
        {
            name: 'assignee', type: 'mystring', useNull: true
        },
        {
            name: 'status', type: 'mystring', useNull: true
        },
        {
            name: 'projectcode', type: 'mystring', useNull: true
        }
    ],
    idProperty: 'deliverableid',

    proxy: {
        type: 'ajax',
        url: '../task',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
