/**
 * ReportTree model.
 */

Ext.define('PTS.model.ReportTree', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'cols',
            type: 'auto'
        },
        {
            name: 'fields',
            type: 'auto'
        },
        {
            name: 'text', type: 'mystring', useNull: true
        },
        {
            name: 'url', type: 'mystring', useNull: true
        },
        {
            name: 'model', type: 'mystring', useNull: true
        },
        {
            name: 'xtype', type: 'mystring', useNull: true
        }
    ],
    idProperty: 'id'
});