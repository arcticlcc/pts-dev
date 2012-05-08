/**
 * Adds checkDirty method to the base fieldcontainer
 */
Ext.define('PTS.view.controls.MyFieldContainer', {
    extend: 'Ext.form.FieldContainer',
    mixins: {
        checkDirty: 'PTS.util.mixin.CheckDirty'
    },
    alias: 'widget.myfieldcontainer',

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
    }
});
