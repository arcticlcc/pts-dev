/**
 * Description: EPSG code model.
 */

Ext.define('PTS.model.EpsgCode', {
    extend: 'PTS.model.Base',
    fields: [
        {
            name: 'srid',
            type: 'int',
            persist: false
        },
        {
            name: 'srid_text',
            type: 'mystring',
            persist: false
        },
        {
            name: 'name', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'srid',

    proxy: {
        type: 'rest',
        url : '../epsg',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
