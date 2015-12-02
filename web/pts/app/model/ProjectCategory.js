/**
 * Description: projectcategory model.
 */

Ext.define('PTS.model.ProjectCategory', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'projectcategoryid',
            type: 'int',
            persist: false
        }, {
            name: 'category',
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
    idProperty: 'projectcategoryid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/projectcategory',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
