/**
 * Model for a Project vector feature(point/line/polygon).
 */
Ext.define('PTS.model.ProjectVector', {
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
        {name: 'projectid', type: 'int', useNull: true},
        {name: 'name', type: 'mystring', useNull: true},
        {name: 'comment', type: 'mystring', useNull: true}
    ],
    /**
     * TODO: This method is included in 4.1, required by GeoExt
     * Gets all values for each field in this model and returns an object
     * containing the current data.
     * @param {Boolean} includeAssociated True to also include associated data. Defaults to false.
     * @return {Object} An object hash containing all the values in this model
     */
    getData: function(includeAssociated){
        var me     = this,
            fields = me.fields.items,
            fLen   = fields.length,
            data   = {},
            name, f;

        for (f = 0; f < fLen; f++) {
            name = fields[f].name;
            data[name] = me.get(name);
        }

        if (includeAssociated === true) {
            Ext.apply(data, me.getAssociatedData());
        }
        return data;
    }
});
