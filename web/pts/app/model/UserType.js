/**
 * Description: UserType model.
 */

Ext.define('PTS.model.UserType', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'usertypeid',
            type: 'int',
            persist: false
        }, {
            name: 'usertype',
            type: 'mystring',
            useNull: true
        }, {
            name: 'code',
            type: 'mystring',
            useNull: true
        }, {
            name: 'description',
            type: 'mystring',
            useNull: true
        }

    ],
    idProperty: 'usertypeid',

    proxy: {
        type: 'rest',
        url: '../usertype',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
