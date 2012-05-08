/*
 * File: app/view/button/Edit.js
 * Edit button for project forms/toolbars.
 * Disabled by default.
 * Useful handlers should be supplied in config.
 */

/*
 * Edit
 */
Ext.define('PTS.view.button.Edit', {
    extend: 'Ext.button.Button',
    alias: 'widget.editbutton',

    text: 'Edit',
    iconCls: 'pts-menu-editbasic',
    disabled: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            handler: function(){
                Ext.Msg.alert('Click', 'You clicked on "Edit".');
            }
        });

        me.callParent(arguments);
    }
});
