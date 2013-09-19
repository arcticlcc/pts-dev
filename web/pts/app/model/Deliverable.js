/**
 * File: app/model/Deliverable.js
 * Description: Deliverable model.
 */

Ext.define('PTS.model.Deliverable', {
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
            name: 'parentmodificationid',
            type: 'int',
            useNull: true
        },
        {
            name: 'parentdeliverableid',
            type: 'int',
            useNull: true
        },
        {name: 'deliverabletypeid', type: 'int', useNull: true},
        {name: 'personid', type: 'int', useNull: true},
        {name: 'title', type: 'mystring', useNull: true},
        {name: 'description', type: 'mystring', useNull: true},
        {name: 'duedate', type: 'mydate'},
        {name: 'receiveddate', type: 'mydate'},
        {name: 'startdate', type: 'mydate'},
        {name: 'enddate', type: 'mydate'},
        //{name: 'invalid', type: 'boolean', useNull: true}, //deprecated
        {name: 'publish', type: 'boolean', defaultValue: true, useNull: true},
        {name: 'restricted', type: 'boolean', useNull: true},
        {name: 'accessdescription', type: 'mystring', useNull: true},
        {
            name: 'id',
            persist: false,
            convert: function(v,record) {
                if(record.data.modificationid && record.data.deliverableid) {
                    return record.data.modificationid + '/deliverable/' + record.data.deliverableid;
                }
                return null;
            }
        }
    ],
    idProperty: 'id',

    proxy: {
        type: 'rest',
        url : '../modification',
        api: {
            read:'../modification',
            create: '../deliverable'
        },
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
