/**
 * File: app/store/Persons.js
 * Description: Store of persons
 */

Ext.define('PTS.store.Persons', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Person',

    remoteSort: true,
    remoteFilter: true,
    pageSize: PTS.Defaults.pageSize,
    sorters: {
        property: 'lastname',
        direction: 'ASC'
    },
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/person',
        api: {
            read: PTS.baseURL + '/personlist'
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
