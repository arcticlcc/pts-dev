/**
 * @class PTS.store.Position
 * Store of contact positions.
 */
Ext.define('PTS.store.Positions', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.Position',

    autoLoad: true,
    sorters: [
        'title'
    ],
    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/person',
        api: {
            read: PTS.baseURL + '/personpositionlist'
        },
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
