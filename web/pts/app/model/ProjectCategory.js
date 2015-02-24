/**
 * Description: projectcategory model.
 */

Ext.define('PTS.model.ProjectCategory', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'projectcategoryid',
            type: 'int',
            persist: false
        },
        {
            name: 'category', type: 'mystring', useNull: true
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'projectcategoryid',

    proxy: {
        type: 'rest',
        url : '../projectcategory',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});