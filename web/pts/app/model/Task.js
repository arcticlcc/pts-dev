/**
 * Task model.
 */

Ext.define('PTS.model.Task', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'deliverableid',
        type: 'int'
    }, {
        name: 'contactid',
        type: 'int'
    }, {
        name: 'modificationid',
        type: 'int',
        useNull: true
    }, {
        name: 'projectid',
        type: 'int',
        useNull: true
    }, {
        name: 'title',
        type: 'mystring',
        useNull: true
    }, {
        name: 'duedate',
        type: 'mydate'
    }, {
        name: 'assignee',
        type: 'mystring',
        useNull: true
    }, {
        name: 'status',
        type: 'mystring',
        useNull: true
    }, {
        name: 'projectcode',
        type: 'mystring',
        useNull: true
    }, {
        name: 'shorttitle',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'deliverableid',

    proxy: {
        type: 'ajax',
        url: PTS.baseURL + '/task',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
