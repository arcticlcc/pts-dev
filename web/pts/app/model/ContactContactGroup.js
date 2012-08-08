/**
 * File: app/model/ContactContactGroup.js
 * Description: ContactContactGroup model.
 */

Ext.define('PTS.model.ContactContactGroup', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'contactcontactgroupid',
            type: 'int',
            //persist: false,
            useNull: true
        },
        {
            name: 'contactid',
            type: 'int',
            useNull: true
        },
        {
            name: 'groupid',
            type: 'int',
            useNull: true
        },
        {
            name: 'positionid',
            type: 'int',
            useNull: true
        },
        {
            name: 'priority',
            type: 'int',
            useNull: true,
            defaultValue: 10000 //this is a hack to prevent nulls
        },
        {
            name: 'name',
            persist: false, type: 'mystring', useNull: true
        }
    ],
    idProperty: 'contactcontactgroupid',

    proxy: {
        type: 'rest',
        url : '../contactcontactgroup',
        appendId: true,
        //batchActions: true,
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
