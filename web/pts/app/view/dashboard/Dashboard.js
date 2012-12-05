/**
 * File: app/view/dashboard/Dashboard.js
 * Description: Project dashboard.
 */

Ext.define('PTS.view.dashboard.Dashboard', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.dashboard',
    requires: [
        /*'ArcticPTS.view.DashboardTaskGrid',
        'ArcticPTS.view.DashBoardQuickView',*/
        'PTS.view.dashboard.Calendar',
        'Extensible.calendar.gadget.CalendarListPanel',
        'PTS.view.dashboard.DeliverableList',
        'PTS.view.dashboard.TaskList'
    ],

    layout: {
        type: 'border'
    },
    title: 'Dashboard',

    initComponent: function() {
        var me = this,
        calStore = Ext.create('Extensible.calendar.data.MemoryCalendarStore', {
            data: Ext.create('PTS.data.Calendar'),
            storeId: 'CalendarStore'
        });

        Ext.applyIf(me, {
            items: [{
                    //id:'app-west',
                    region: 'west',
                    width: 179,
                    border: false,
                    items: [{
                        xtype: 'datepicker',
                        id: 'app-nav-picker',
                        cls: 'ext-cal-nav-picker',
                        listeners: {
                            'select': {
                                fn: function(dp, dt){
                                    Ext.ComponentQuery.query('dashboardcalendar')[0].setStartDate(dt);
                                },
                                scope: this
                            }
                        }
                    },{
                        xtype: 'extensible.calendarlist',
                        store: calStore,
                        border: false,
                        width: 178
                    }]
                },
                {
                    xtype: 'dashboardcalendar',
                    id: 'pts-dashboardcalendar',
                    calendarStore: calStore,
                    bodyPadding: '',
                    //border: '0 1 0 1',
                    style: {
                        border: "1px",
                        padding: 0
                    },
                    //title: 'Calendar',
                    //flex: 1,
                    region: 'center',
                    viewConfig: {
                        showHeader: true
                    }
                },
                {
                    xtype: 'tabpanel',
                    width: Ext.getBody().getWidth() > 1490 ? 700 : 590,
                    title: 'Tasks and Deliverables',
                    minWidth: 550,
                    //flex: 1,
                    region: 'east',
                    collapsible: true,
                    split: true,
                    preventHeader: true,
                    animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                    items: [
                        {
                            xtype: 'tasklist',
                            title: 'Tasks'
                        },
                        {
                            xtype: 'deliverablelist',
                            title: 'Deliverables'
                        }
                    ]
                }/*,
                {
                    xtype: 'dashboardquickview',
                    region: 'south',
                    collapsed: true
                }*/
            ]
        });

        me.callParent(arguments);
    }

});
