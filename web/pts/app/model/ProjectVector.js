/**
 * Model for a Project vector feature(point/line/polygon).
 */
Ext.define('PTS.model.ProjectVector', {
    extend: 'PTS.model.Base',
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
        {name: 'projectid', type: 'int', useNull: true},
        {name: 'name', type: 'mystring', useNull: true},
        {name: 'comment', type: 'mystring', useNull: true}
    ]
});
