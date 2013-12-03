/**
 * @author Joshua Bradley
 * TPS record model.
 */

Ext.define('PTS.model.TpsRecord', {
    extend: 'Ext.data.Model',
    //requires: ['PTS.util.DataTypes'],
    fields: [
        {
            name: 'modificationid',
            type: 'int',
            persist: false
        }
    ],
    idProperty: 'modificationid',

    proxy: {
        type: 'ajax',
        url : '../report/tps',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
