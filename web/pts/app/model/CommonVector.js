/**
 * Model for common Project vector features(point/line/polygon).
 */
Ext.define('PTS.model.CommonVector', {
    extend: 'Ext.data.Model',
    fields: [
        {name: 'id', type: 'int', useNull: true},
        {name: 'text', type: 'mystring', useNull: true},
        {name: 'comment', type: 'mystring', useNull: true},
        {name: 'wkt', type: 'mystring', useNull: true}
    ],

    proxy: {
        type: 'ajax',
        url : '../commonfeature',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
