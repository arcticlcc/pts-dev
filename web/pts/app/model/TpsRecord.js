/**
 * @author Joshua Bradley
 * TPS record model.
 */

Ext.define('PTS.model.TpsRecord', {
    extend: 'PTS.model.Base',
    //requires: ['PTS.util.DataTypes'],
    fields: [{
        name: 'modificationid',
        type: 'int',
        persist: false
    }],
    idProperty: 'modificationid',

    proxy: {
        type: 'ajax',
        url: PTS.baseURL + '/report/tps',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
