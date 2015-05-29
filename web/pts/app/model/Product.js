/**
 * Product model.
 */

Ext.define('PTS.model.Product', {
    extend: 'Ext.data.Model',

    fields: [
        {
            name: 'productid',
            type: 'int',
            persist: false
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
            name: 'startdate',
            type: 'mydate'
        },
        {
            name: 'enddate',
            type: 'mydate'
        },
        {
            name: 'description', type: 'mystring', useNull: true
        },
        {
            name: 'abstract', type: 'mystring', useNull: true
        },
        {
            name: 'purpose', type: 'mystring', useNull: true
        },
        {
            name: 'uuid',
            persist: false
        },
        {
            name: 'exportmetadata',
            type: 'myboolean'
        }
    ],

    idProperty: 'productid',

    proxy: {
        type: 'rest',
        url : '../product',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
