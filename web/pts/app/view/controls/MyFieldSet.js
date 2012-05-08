/**
 * Adds checkDirty method to the base fieldset
 */
Ext.define('PTS.view.controls.MyFieldSet', {
    extend: 'Ext.form.FieldSet',
    alias: 'widget.myfieldset',
    mixins: {
        checkDirty: 'PTS.util.mixin.CheckDirty'
    },

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
    }
});
