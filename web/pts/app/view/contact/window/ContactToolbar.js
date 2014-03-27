/**
 * @class PTS.view.contact.window.ContactToolbar
 */
Ext.define('PTS.view.contact.window.ContactToolbar', {
    extend: 'Ext.toolbar.Toolbar',
    alias: 'widget.contacttoolbar',
    requires: [
        'Ext.toolbar.*'
    ],

    dock: 'top',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'button',
                    text: 'Edit',
                    iconCls: 'pts-menu-editbasic',
                    hidden: true,
                    action: 'editcontact'
                },
                {
                    xtype: 'button',
                    text: 'Delete',
                    iconCls: 'pts-menu-deletebasic',
                    //disabled: true,
                    action: 'deletecontact'
                },
                {
                    xtype: 'button',
                    text: 'Save',
                    iconCls: 'pts-menu-savebasic',
                    //formBind: true,
                    action: 'savecontact'
                },
                {
                    xtype: 'button',
                    text: 'Reset',
                    iconCls: 'pts-menu-reset',
                    //formBind: true,
                    //disabled: true,
                    action: 'resetcontact'
                }
            ]
        });

        me.callParent(arguments);
    }
});
