/**
 * Store of Calendar definitions.
 * Not used.
 */
Ext.define('PTS.store.CalendarStore', {
    extend: 'Extensible.calendar.data.MemoryCalendarStore',
    requires: [
        'PTS.data.Calendar',
        'Extensible.calendar.data.CalendarModel',
        'Extensible.calendar.data.CalendarMappings'
    ],

    data:{
        "calendars":[
            {
                "cal_id":"C1",
                "cal_title":"Past Due",
                "cal_color":2
            },{
                "cal_id":"C2",
                "cal_title":"Due Immediately",
                "cal_color":6
            },{
                "cal_id":"C3",
                "cal_title":"Due Soon",
                "cal_color":20
            },{
                "cal_id":"C4",
                "cal_title":"Completed",
                "cal_color":26
            }
        ]
    },

    constructor: function(config) {
        config = config || {};
        Extensible.calendar.data.CalendarMappings = {
            CalendarId:   {name:'ID', mapping: 'cal_id', type: 'string'}, // int by default
            Title:        {name:'CalTitle', mapping: 'cal_title', type: 'string'},
            Description:  {name:'Desc', mapping: 'cal_desc', type: 'string'},
            ColorId:      {name:'Color', mapping: 'cal_color', type: 'int'},
            IsHidden:     {name:'Hidden', mapping: 'hidden', type: 'boolean'}
        };
        // Don't forget to reconfigure!
        Extensible.calendar.data.CalendarModel.reconfigure();

        this.callParent(arguments);
    },

    initComponent: function() {
        this.callParent(arguments);
    }
});
