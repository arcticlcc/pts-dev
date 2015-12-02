/**
 * Position model.
 */
Ext.define('PTS.model.Position', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'positionid',
        type: 'int'
    }, {
        name: 'title',
        type: 'mystring',
        useNull: true
    }, {
        name: 'code',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'positionid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/position',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
