/**
 * File: app/store/Persons.js
 * Description: Store of persons
 */

Ext.define('PTS.store.Persons', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Person',

    pageSize: PTS.Defaults.pageSize,
    sorters: { property: 'lastname', direction : 'ASC' },
    proxy: {
        type: 'rest',
        url : '../person',
        api: {
            read:'../personlist'
        },
        reader: {
            type: 'json',
            root: 'data'
        },
        writer: {
            type: 'ajson'
        }
    }
});
