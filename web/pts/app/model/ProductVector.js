/**
 * Model for a Product vector feature(point/line/polygon).
 */
Ext.define('PTS.model.ProductVector', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'fid',
            convert: function(value, record) {
                // record.raw a OpenLayers.Feature.Vector instance
                if (record.raw instanceof OpenLayers.Feature.Vector) {
                    return record.raw.fid;
                } else {
                    return "This is not a Feature";
                }
            }
        },
        {name: 'productid', type: 'int', useNull: true},
        {name: 'name', type: 'mystring', useNull: true},
        {name: 'comment', type: 'mystring', useNull: true}
    ]
});
