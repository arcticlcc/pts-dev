/**
 * ReportTree model.
 */

Ext.define('PTS.model.ReportTree', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'cols',
        type: 'auto'
    }, {
        name: 'fields',
        type: 'auto'
    }, {
        name: 'text',
        type: 'mystring',
        useNull: true
    }, {
        name: 'url',
        type: 'mystring',
        useNull: true
    }, {
        name: 'model',
        type: 'mystring',
        useNull: true
    }, {
        name: 'xtype',
        type: 'mystring',
        useNull: true
    }, {
        name: 'limit',
        type: 'int',
        defaultValue: PTS.Defaults.pageSize
    }, {
        name: 'summary',
        type: 'myboolean',
        defaultValue: false
    }, {
        name: 'filterBar',
        type: 'myboolean',
        defaultValue: false
    }, {
        name: 'remoteFilter',
        type: 'myboolean',
        defaultValue: false
    }, {
        name: 'pbarPlugins',
        type: 'auto'
    }, {
        name: 'pbarItems',
        type: 'auto'
    }],
    idProperty: 'id'
});
