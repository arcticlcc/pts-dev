/**
 * Description: ModificationContact model.
 */

Ext.define('PTS.model.ModificationContact', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'modificationid',
        type: 'int',
        persist: false
    }, {
        name: 'modificationcontact',
        type: 'auto',
        useNull: true,
        convert: function(v) {
            return Ext.isString(v) ? v.split(',') : v;
        }
    }],
    idProperty: 'modificationid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/modificationcontact',
        api: {
            read: PTS.baseURL + '/modificationcontactlist'
        },
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
