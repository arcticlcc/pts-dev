/**
 * @class PTS.controller.dashboard.Calendar
 */
Ext.define('PTS.controller.dashboard.Calendar', {
    extend: 'Ext.app.Controller',
    requires: [
        'Extensible.calendar.data.EventModel',
        'Extensible.calendar.data.CalendarModel'
    ],

    views: [
        'dashboard.Calendar'
    ],

    init: function() {

        this.control({
            'dashboardcalendar': {
                eventclick: this.eventClick
            }
        });

        Extensible.calendar.data.EventMappings = {
            // These are the same fields as defined in the standard EventRecord object but the
            // names and mappings have all been customized. Note that the name of each field
            // definition object (e.g., 'EventId') should NOT be changed for the default fields
            // as it is the key used to access the field data programmatically.

            // We can also add some new fields that do not exist in the standard EventRecord:
            CreatedBy:      {name: 'Manager', mapping: 'manager'},
            DateReceived:   {name: 'Received', mapping:'receiveddate', type: 'mydate'},
            PersonId:       {name: 'PersonID', mapping:'personid', type:'int'},
            Type:           {name: 'Type', mapping:'type', type:'string'},
            ProjectCode:    {name: 'ProjectCode', mapping:'projectcode', type:'string'},
            ProjectTitle:   {name: 'ProjectTitle', mapping:'shorttitle', type:'string'},
            ProjectId:      {name: 'projectid', mapping:'projectid', type:'int'},
            ModificationId: {name: 'modificationid', mapping:'modificationid', type:'int'},
            Status:         {name: 'Status', mapping:'status', type:'string',
                                convert: function(v) {
                                    return v ? v : 'Not Received';
                                }
                            },
            Completed:      {name: 'Completed', mapping:'completed', type:'mybool'},
            //standard EventRecord fields
            EventId:     {name: 'ID', mapping:'deliverableid', type:'int'}, // int by default
            CalendarId:  {name: 'CalendarId', mapping: 'id', type: 'int', convert: this.getCalendar}, // int by default
            Title:       {name: 'EvtTitle', mapping: 'title'},
            StartDate:   {name: 'StartDt', mapping: 'duedate', type: 'mydate'},
            EndDate:     {name: 'EndDt', mapping: 'duedate', type: 'mydate'},
            RRule:       {name: 'RecurRule', mapping: 'recur'},
            Location:    {name: 'Location', mapping: 'location'},
            Notes:       {name: 'Desc', mapping: 'description'},
            Url:         {name: 'LinkUrl', mapping: 'uri'},
            IsAllDay:    {name: 'AllDay', mapping: 'allday', type: 'boolean', defaultValue: true},
            Reminder:    {name: 'Reminder', mapping: 'reminder'}
        };

        // Don't forget to reconfigure!
        Extensible.calendar.data.EventModel.reconfigure();

        //add ProjectCode method to model to support openproject method
        Extensible.calendar.data.EventModel.implement({
            getProjectCode: function(){
                return this.get('ProjectCode');
            }
        });

        /*Extensible.calendar.data.CalendarMappings = {
            CalendarId:   {name:'ID', mapping: 'cal_id', type: 'string'}, // int by default
            Title:        {name:'CalTitle', mapping: 'cal_title', type: 'string'},
            Description:  {name:'Desc', mapping: 'cal_desc', type: 'string'},
            ColorId:      {name:'Color', mapping: 'cal_color', type: 'int'},
            IsHidden:     {name:'Hidden', mapping: 'hidden', type: 'boolean'}
        };
        // Don't forget to reconfigure!
        Extensible.calendar.data.CalendarModel.reconfigure();*/

        // One key thing to remember is that any record reconfiguration you want to perform
        // must be done PRIOR to initializing your data store, otherwise the changes will
        // not be reflected in the store's records.
        /*Ext.create('Extensible.calendar.data.MemoryCalendarStore', {
                            // defined in ../data/CalendarsCustom.js
                            data: Ext.create('PTS.data.Calendar'),
                            storeId: 'Calstore'
                        });*/
        /*this.control({
            'dashboardcalendar': {
                eventclick: function(cal, rec, el){
                    console.info(rec);
                }
            }
        });*/
    },

    /**
     * Return the appropriate calendar id for the passed record
     * @param {Mixed} v The value from the model
     * @param {Ext.data.Model} rec The event record
     * @return {String} The calendar id defined by {PTS.data.Calendar}.
     *
     */
    getCalendar: function(v, rec) {
        var dt = rec.data.StartDt,
            today = new Date();

        //set the date to 11:59pm of the current day
        today.setHours(0,0,0,0);
        if(rec.data.Status === 'Overdue') {
            return 1; //Overdue, set manually
        }else if(rec.data.Completed) {
            return 5; //Complete
        }else if(rec.data.Received) {
            return 4; //Received
        }else if (dt < today) {
            return 1; //late
        }else if (dt > Ext.Date.add(today, Ext.Date.DAY, 30)) {
            return 3; //due more than 30 days into the future
        }else {
            return 2; //due within 30 days
        }
    },

    /**
     * Handle event clicks
     * @param {PTS.view.dashboard.Calendar} panel The calendar panel
     * @param {Ext.data.Model} rec The event record
     */
    eventClick: function(panel, rec) {
        //Ext.getBody().mask('Loading...');
        //console.info(rec);
        //p = Ext.getStore('ProjectListings').getById(9);
        this.getController('dashboard.Dashboard').openProject(panel,rec);

        /*var id = rec.getId(),
            modid = rec.get('modificationid'),
            callBack = function() {
            var win = this,
                store = win.down('agreementstree').getStore(),
                tab = win.down('projectagreements'),
                setPath = function(store) {
                    var path = store.getNodeById("d-"+id+"-"+modid).getPath();
                    this.down('agreementstree').selectPath(path);
                    this.getEl().unmask();
                };

            //Ext.getBody().unmask();
            win.getEl().mask('Loading...');
            win.down('tabpanel').setActiveTab(tab);

            if(store.getRootNode().hasChildNodes()) {
                setPath(store);
            }else {
                store.on('load', setPath, win, {
                    single: true
                });
            }
        };

        this.getController('project.Project').openProject(rec,callBack);*/
    }
});
