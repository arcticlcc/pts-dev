/**
 * File: app/view/dashboard/Calendar.js
 *
 * Description: Dashboard calendar displaying deliverables and tasks.
 */

Ext.define('PTS.view.dashboard.Calendar', {
    extend: 'Extensible.calendar.CalendarPanel',
    alias: 'widget.dashboardcalendar',
    requires: [
        'Extensible.calendar.data.MemoryEventStore',
        'Extensible.calendar.data.MemoryCalendarStore',
        'Extensible.calendar.data.EventStore',
        'Extensible.calendar.CalendarPanel',
        'PTS.data.Calendar', //calendar definition
        'Extensible.calendar.data.CalendarMappings',
        'Extensible.calendar.data.EventMappings'
    ],

    showDayView: false,
    showWeekView: false,
    readOnly: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            eventStore: Ext.create('Extensible.calendar.data.EventStore', {
                    autoLoad: true,
                    pageSize: undefined,
                    proxy: {
                        type: 'rest',
                        url: '../deliverable/calendar',
                        noCache: true,

                        reader: {
                            type: 'json',
                            root: 'data'
                        },

                        listeners: {
                            exception: function(proxy, response, operation, options){
                                var msg = response.message ? response.message : Ext.decode(response.responseText).message;
                                // ideally an app would provide a less intrusive message display
                                Ext.Msg.alert('Server Error', msg);
                            }
                        }
                    }
            })/*,
            calendarStore: Ext.create('Extensible.calendar.data.MemoryCalendarStore', {
                    // defined in ../data/CalendarsCustom.js
                    data: Ext.create('PTS.data.Calendar')
                })*/
        });

        me.callParent(arguments);
    }
});
