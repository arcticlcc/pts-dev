/**
 * File: app/view/MainToolbar.js
 * Description: Main toolbar for the application. Positioned at top (north) of viewport.
 */

Ext.define('PTS.view.MainToolbar', {
    extend: 'Ext.toolbar.Toolbar',
    alias: 'widget.maintoolbar',
    height: 33,
    id: 'pts-main-toolbar',
    itemId: 'main-toolbar',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            style: {
                border: 'none',
                backgroundColor: '#FFF',
                backgroundImage: 'none'
            },
            items: [
                {
                    xtype: 'tbtext',
                    html: '<h1>Arctic LCC Project Tracking System</h1>',
                    style: {
                        textAlign: 'center',
                        fontSize: '18px'
                    },
                    flex: 1
                },
                {
                    xtype: 'container',
                    width: 200,
                    items: [
                        {
                            xtype: 'label',
                            margin: '0 5',
                            text: 'Logged In:'
                        },
                        {
                            xtype: 'button',
                            itemId: 'userBtn',
                            text: '',
                            menu: {
                                xtype: 'menu',
                                items: [
                                    {
                                        xtype: 'menuitem',
                                        iconCls: 'pts-menu-settings',
                                        text: 'Settings'
                                    },
                                    {
                                        xtype: 'menuitem',
                                        iconCls: 'pts-menu-logout',
                                        text: 'Logout',
                                        //TODO: move to controller
                                        handler: function() {
                                            window.location = 'logout';
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
