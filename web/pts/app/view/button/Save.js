/*
 * File: app/view/button/Save.js
 * Save button for project forms/toolbars.
 * Disabled by default.
 * Useful handlers should be supplied in config.
 */

/*
 * Save
 */
Ext.define('PTS.view.button.Save', {
    extend: 'Ext.button.Button',
    alias: 'widget.savebutton',

    text: 'Save',
    iconCls: 'pts-menu-savebasic',
    disabled: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            handler: function() {
                Ext.Msg.alert('Click', 'You clicked on "Save".');
            }
        });

        me.callParent(arguments);
    }
});
