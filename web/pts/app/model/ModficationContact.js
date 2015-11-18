/**
 * Description: ModficationContact model.
 */

Ext.define('PTS.model.ModficationContact', {
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
        url: '../modificationidprojectcontact',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
