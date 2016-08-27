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
            items: [{
                xtype: 'tbtext',
                html: '<h1>' + PTS.UserId.title + ' Project Tracking System <span class="pts-version">v' + PTS.app.version + '</span></h1>',
                style: {
                    textAlign: 'center',
                    fontSize: '18px'
                },
                flex: 1
            }, {
                xtype: 'container',
                width: 200,
                items: [{
                    xtype: 'label',
                    margin: '0 5',
                    text: 'Logged In:'
                }, {
                    xtype: 'button',
                    itemId: 'userBtn',
                    text: '',
                    menu: {
                        xtype: 'menu',
                        items: [{
                            xtype: 'menuitem',
                            itemId: 'configBtn',
                            iconCls: 'pts-menu-settings',
                            text: 'Settings'
                        }, {
                            xtype: 'menuitem',
                            itemId: 'issueBtn',
                            iconCls: 'pts-menu-exclamation',
                            text: 'Create Issue',
                            tooltip: 'Test'
                        }, {
                            itemId: 'switchPTS',
                            iconCls: 'pts-menu-switch',
                            text: 'Switch PTS',
                            menu: {
                                /*defaults: {
                                    iconCls: 'pts-menu-switch'
                                },*/
                                plain: true,
                                items: []
                            }
                        }, {
                            xtype: 'menuitem',
                            iconCls: 'pts-menu-logout',
                            text: 'Logout',
                            //TODO: move to controller
                            handler: function() {
                                window.location = 'logout';
                            }
                        }]
                    }
                }]
            }]
        });

        me.callParent(arguments);
    }
});
