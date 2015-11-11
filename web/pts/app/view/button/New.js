/*
 * File: app/view/button/New.js
 * New button for project forms/toolbars.
 * Disabled by default.
 * Useful handlers should be supplied in config.
 */

/*
 * New
 */
Ext.define('PTS.view.button.New', {
    extend: 'Ext.button.Button',
    alias: 'widget.newbutton',

    text: 'New',


    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            iconCls: 'pts-menu-addbasic',
            disabled: true,
            handler: function() {

                Ext.Msg.alert('Click', 'You clicked on "New".');
            }
        });

        me.callParent(arguments);
    }
});
