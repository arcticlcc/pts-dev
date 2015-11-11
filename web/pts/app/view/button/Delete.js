/*
 * File: app/view/button/Delete.js
 * Delete button for project forms/toolbars.
 * Disabled by default.
 * Useful handlers should be supplied in config.
 */

/*
 * Delete
 */
Ext.define('PTS.view.button.Delete', {
    extend: 'Ext.button.Button',
    alias: 'widget.deletebutton',

    text: 'Delete',
    iconCls: 'pts-menu-deletebasic',
    disabled: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            handler: function() {
                Ext.Msg.alert('Click', 'You clicked on "Delete".');
            }
        });

        me.callParent(arguments);
    }
});
