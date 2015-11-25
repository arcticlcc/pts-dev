/**
 * UserConfig model for persistent application settings.
 */

Ext.define('PTS.model.UserConfig', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'loginid',
        type: 'int',
        persist: false
    }, {
        name: 'windowWidth',
        type: 'int',
        persist: false,
        defaultValue: '900'
    }],
    idProperty: 'loginid',

    proxy: {
        type: 'rest',
        url: '../userinfo/config',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
