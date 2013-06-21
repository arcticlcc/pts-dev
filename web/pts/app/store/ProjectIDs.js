/**
 * Store of project ids for lookups, comboboxes
 */

Ext.define('PTS.store.ProjectIDs', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Project',

    fields: [
        {
            name: 'projectid',
            type: 'int'
        },
        {
            name: 'projectcode',
            type: 'string'
        },
        {
            name: 'title'
        },
        {
            name: 'shorttitle'
        }
    ],
    proxy: {
        type: 'rest',
        url : '../project',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    },
    autoLoad: false,
    sorters: [
        { property: 'fiscalyear', direction : 'DESC' },
        { property: 'number', direction : 'DESC' }
    ]
});
