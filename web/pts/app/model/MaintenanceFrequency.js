/**
 * Description: maintenanceFrequency model.
 */

Ext.define('PTS.model.MaintenanceFrequency', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'maintenancefrequencyid',
            type: 'int',
            persist: false
        }, {
            name: 'code',
            type: 'mystring',
            useNull: true
        }, {
            name: 'codename',
            type: 'mystring',
            useNull: true
        }, {
            name: 'description',
            type: 'mystring',
            useNull: true
        }

    ],
    idProperty: 'maintenancefrequencyid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/maintenancefrequency',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
