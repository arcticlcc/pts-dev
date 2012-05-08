/**
 * Date field that recomputes allowed dates on change.
 * Should be configured to use PTS.util.VTypes#daterange
 */
Ext.define('PTS.view.controls.DateRangeField', {
    extend: 'Ext.form.field.Date',
    alias: 'widget.daterangefield',

    initComponent: function() {
        var me = this;

        me.callParent(arguments);

        me.on('change', function(field, newValue, oldValue) {
            if (newValue === null) {
                Ext.form.field.VTypes.daterange(newValue, field);
            }
        });
    }
});
