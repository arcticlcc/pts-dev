/**
 * Custom Date Types
 */
Ext.define('PTS.util.DataTypes', {
    singleton: true,
    requires: [
        'Ext.data.Types',
        'Ext.data.SortTypes'
    ]
}, function() {
        var st = Ext.data.SortTypes;

        //this sets the returned dateFormat
        //assumes Y-m-d is acceptable!!!
        //TODO: look for fix in future verstion of Ext
        //http://www.sencha.com/forum/showthread.php?176637-Ext.data.writer.Json-no-longer-respects-dateFormat
        Ext.JSON.encodeDate = function(o) {
            return Ext.Date.format(o, '"Y-m-d"');   //make sure the results are fully quoted !
        };

        // Add a new Date Field data type which defaults to 'Y-m-d' dateFormat.
        Ext.data.Types.MYDATE = {
            convert: function(v) {
                var df = 'Y-m-d',
                    parsed;

                if (!v) {
                    return null;
                }
                if (Ext.isDate(v)) {
                    return v;
                }
                if (df) {
                    if (df === 'timestamp') {
                        return new Date(v*1000);
                    }
                    if (df === 'time') {
                        return new Date(parseInt(v, 10));
                    }
                    return Ext.Date.parse(v, df);
                }

                parsed = Date.parse(v);
                return parsed ? new Date(parsed) : null;
            },
            sortType: st.asDate,
            type: 'mydate'
        };

        // Add a new Boolean data type which returns 1 or 0 for Php/Postgresql compat.
        // Otherwise, js boolean value 'false' is converted into an empty string when submitted.
        Ext.data.Types.MYBOOLEAN = {
            convert: function(v) {
                if (this.useNull && (v === undefined || v === null || v === '')) {
                    return null;
                }
                return (v !== 'false') && !!v ? 1 : 0;
            },
            sortType: st.none,
            type: 'myboolean'
        };

        // Add a new String data type which returns null when null/undefined/empty string.
        Ext.data.Types.MYSTRING = {
            convert: function(v) {
                if (v === undefined || v === null || v === '') {
                    return null;
                }
                return v;
            },
            sortType: function(v) {
                if (v === undefined || v === null || v === '') {
                    return null;

                }
                return String(v).toUpperCase();

            },
            type: 'mystring'
        };
    }
);
