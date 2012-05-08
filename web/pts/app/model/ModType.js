/**
 * File: app/model/ModType.js
 * Description: ModType model.
 */

Ext.define('PTS.model.ModType', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'modtypeid',
            type: 'int',
            persist: false
        },
        {
            name: 'code', type: 'mystring', useNull: true
        },
        {
            name: 'type', type: 'mystring', useNull: true
        },
        {
            name: 'description', type: 'mystring', useNull: true
        }

    ],
    idProperty: 'modtypeid',

    proxy: {
        type: 'rest',
        url : '../modtype',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
