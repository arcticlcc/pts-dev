/**
 * Description: TopicCategory model.
 */

Ext.define('PTS.model.TopicCategory', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'topiccategoryid',
            type: 'int',
            persist: false
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'codename', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'topiccategoryid',

    proxy: {
        type: 'rest',
        url : '../topiccategory',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
