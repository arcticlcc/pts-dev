/**
 * Position model.
 */
Ext.define('PTS.model.Position', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'positionid',
            type: 'int'
        },
        {
            name: 'title', type: 'mystring', useNull: true
        },
        {
            name: 'code', type: 'mystring', useNull: true
        }
    ],
    idProperty: 'positionid',

    proxy: {
        type: 'rest',
        url : '../position',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
