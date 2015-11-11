/**
 * Generic combobox that clears any filters on it's store when destroyed.
 */
Ext.define('PTS.view.controls.MyCombo', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.mycombo',
    requires: ['Ext.form.field.ComboBox'],

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
        //clear the filter when the combo is destroyed
        me.on('beforedestroy', function(cmb) {
            cmb.getStore().clearFilter(false);
        });
    }
});
