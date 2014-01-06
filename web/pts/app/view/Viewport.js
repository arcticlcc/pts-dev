/**
 * Main app Viewport
 */

Ext.define('PTS.view.Viewport', {
    extend: 'Ext.container.Viewport',
    requires: [
        'PTS.view.MainToolbar',
        'PTS.view.dashboard.Dashboard',
        'PTS.view.project.tab.ProjectTab',
        'PTS.view.contact.tab.ContactTab',
        'PTS.view.report.tab.ReportTab',
        'PTS.view.tps.tab.TpsTab'
    ],

    layout: {
        type: 'border'
    },
    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'tabpanel',
                    style: {
                        border: 'none',
                        backgroundColor: '#FFF',
                        backgroundImage: 'none'
                    },
                    bodyPadding: 0,
                    preventHeader: true,
                    title: 'Main',
                    activeTab: 0,
                    plain: true,
                    region: 'center',
                    items: [
                        {
                            xtype: 'dashboard'
                        },
                        {
                            xtype: 'projecttab'
                        },
                        {
                            xtype: 'contacttab',
                            title: 'Contacts'
                        },
                        {
                            xtype: 'reporttab'
                        },
                        {
                            xtype: 'tpstab'
                        }
                    ]
                },
                {
                    xtype: 'maintoolbar',
                    region: 'north'
                },
                {
                    xtype: 'toolbar',
                    height: 20,
                    hidden: true,
                    //id: 'pts-status-toolbar',
                    itemId: 'status-toolbar',
                    flex: 0,
                    region: 'south',
                    items: [
                        {
                            xtype: 'tbtext',
                            text: 'My Text'
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
