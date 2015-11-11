/*
 * File: app/view/button/Reset.js
 * Reset button for project forms/toolbars.
 * Disabled by default.
 * Useful handlers should be supplied in config.
 */

/*
 * Reset
 */
Ext.define('PTS.view.button.Reset', {
    extend: 'Ext.button.Button',
    alias: 'widget.resetbutton',

    text: 'Reset',
    iconCls: 'pts-menu-reset',
    disabled: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            handler: function() {
                Ext.Msg.alert('Click', 'You clicked on "Reset".');
            }
        });

        me.callParent(arguments);
    }
});
