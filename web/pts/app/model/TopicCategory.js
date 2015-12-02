/**
 * Description: TopicCategory model.
 */

Ext.define('PTS.model.TopicCategory', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'topiccategoryid',
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
    idProperty: 'topiccategoryid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/topiccategory',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
