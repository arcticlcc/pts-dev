/**
 * @class PTS.util.AssociationJsonWriter
 * @extends Ext.data.writer.Writer
 *
 * This class is used to write {@link Ext.data.Model} data to the server in a JSON format.
 * The default {@link Ext.data.writer.Writer#getRecordData} method has been overridden to include data from associations.
 */
Ext.define('PTS.util.AssociationJsonWriter', {
    extend: 'Ext.data.writer.Json',
    alternateClassName: 'Ext.data.AssociationJsonWriter',
    alias: 'writer.ajson',

    getRecordData: function(record) {
        var isPhantom = record.phantom === true,
            writeAll = this.writeAllFields || isPhantom,
            nameProperty = this.nameProperty,
            fields = record.fields,
            data = {},
            changes,
            name,
            field,
            key;

        if (writeAll) {
            fields.each(function(field){
                if (field.persist) {
                    name = field[nameProperty] || field.name;
                    data[name] = record.get(field.name);
                }
            });
        } else {
            // Only write the changes
            changes = record.getChanges();
            for (key in changes) {
                if (changes.hasOwnProperty(key)) {
                    field = fields.get(key);
                    name = field[nameProperty] || field.name;
                    data[name] = changes[key];
                }
            }
            if (!isPhantom) {
                // always include the id for non phantoms
                data[record.idProperty] = record.getId();
            }
        }

        if(record.associations.items.length) {//check for associations
            //loop thru associations
            record.associations.each(function(assoc){
                var store = record[assoc.name](),
                    proxy = store.getProxy(),
                    rdata = [];
                //and get dirty records
                store.each(function(r) {
                    if(r.dirty){
                        rdata.push(proxy.getWriter().getRecordData(r));
                    }
                    data[assoc.name] = rdata;
                },this);
            },this);
        }
        return data;
    }
});
