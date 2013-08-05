/**
 * @class PTS.app
 * @author Josh Bradley <joshua_bradley@fws.gov>
 * The PTS application bootstrap file
 *
 * **TODO**:
 *
 * - Document application level events
 */

Ext.Loader.setConfig({
    enabled: true,
    paths: {
        'Extensible': 'extensible-1.5.1/src',
        'Extensible.example': 'extensible-1.5.1/examples',
        'Ext.ux': './ux',
        'GeoExt': './lib/geoext/src/GeoExt'
    },
    disableCaching: true
});

Ext.application({
    requires: [
        'PTS.Defaults',
        'PTS.model.User', //not requesting with just models config
        'PTS.util.DataTypes', //custom datatypes/
        'PTS.util.VTypes', //custom validation types/
        'PTS.Overrides',
        'PTS.util.ActivityMonitor',
        'PTS.util.AssociationJsonWriter',//custom writer
        'Ext.ux.window.Notification'
    ],
    name: 'PTS',
    version: '0.9.2',

    appFolder: 'app',
    autoCreateViewport: false,
    enableQuickTips: true,

    models: ['User'],
    stores: ['States', 'Countries', 'Positions'],
    controllers: [
        'MainToolbar',
        'dashboard.Dashboard',
        'project.Project',
        'contact.Contact',
        'report.Report'

    ],

    /**
     * @event newitem
     * Fired when a new {@link Ext.data.Model#phantom phantom} model is loaded into
     * an {@link PTS.view.project.window.ItemDetail ItemDetail} form.
     * @param {Ext.data.Model} model The Model instance that was loaded into the form
     * @param {Ext.form.Panel} form The form panel for the item, use ownerCt to get the card
     */

    /**
     * Store the last application error.
     * @param {String} txt The error string.
     */
    setError: function(txt) {
        this.lastError = txt;
    },

    /**
     * Retrieve the last application error.
     * @return {String} The last recorded error.
     */
    getError: function() {
        return this.lastError;
    },

    /**
     * Creates an error notification.
     * @param {String} txt The error string.
     */
    showError: function(txt) {
        Ext.create('widget.uxNotification', {
            title: 'Error',
            iconCls: 'ux-notification-icon-error',
            html: txt
        }).show();
    },

    /**
     * Launch the application.
     */
    launch: function() {
        var me = this,
            task,
            myMask = new Ext.LoadMask(Ext.getBody(), {msg:"Please wait...Fetching User Info"});

        myMask.show(); //mask the window body

        //get user details
        me.getModel('PTS.model.User').load(UserId.id,{

            success: function(user) {
                var store = this.getStore('GroupUsers');

                PTS.user = user;//save user details
                PTS.orgcode = PTS.user.get('acronym'); //set orgcode

                //set the GroupUsers proxy using the PTS.user groupid
                store.setProxy({
                    type: 'ajax',
                    url : '../contactgroup/' + PTS.user.get('groupid') + '/person',
                    reader: {
                        type: 'json',
                        root: 'data'
                    },
                    //For ALCC, we only want staff not SC members
                    extraParams: {
                        filter: Ext.encode([
                            {
                                property: 'positionid',
                                value   : ['where not in',[96, 85]]
                            }
                        ])
                    }
                });
                //TODO: Account for ability to change groups,
                //this store will need to be reloaded.
                store.load();

                Ext.create('PTS.view.Viewport');

                myMask.destroy();

                //setup activity monitor
                PTS.util.ActivityMonitor.init({
                    verbose : false,
                    interval: (1000*900*1), //15 minutes
                    maxInactive: (1000*13470*1), //224.5 minutes
                    isActive: function() {
                        Ext.Ajax.request({
                            url: '../poll'
                        });
                    },
                    isInactive: function() {
                        var win = Ext.create('Ext.window.MessageBox', {
                            buttonText: {
                                ok: "Keep Working"
                            }
                        });
                        win.show({
                            buttons: Ext.MessageBox.OK,
                            closable: false,
                            fn: function(btn) {
                                Ext.TaskManager.stop(win.task);
                                PTS.util.ActivityMonitor.start(); //restart monitor
                            },
                            msg: "Your session has been idle for too long. Click the button to keep working.",
                            progress: true,
                            scope: this,
                            title: "Inactivity Warning"
                        });
                        win.updateProgress(0);
                        win.seconds = 0;
                        win.task = Ext.TaskManager.start({
                            run: function () {
                                win.seconds += 1;
                                if (win.seconds > 6) {
                                    Ext.TaskManager.stop(win.task);
                                    window.location = '../logout'; //logout
                                } else {
                                    win.updateProgress(win.seconds / 6);
                                }
                            },
                            scope: this,
                            interval: (1000*2) //ten seconds
                        });
                    }
                });

                //delay the monitor start for 20 sec
                task = new Ext.util.DelayedTask(function() {
                    PTS.util.ActivityMonitor.start();
                });
                task.delay(20000);
            },
            failure: function(user, op) {
                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'There was an error.',
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   //fn: showResult,
                   icon: Ext.Msg.ERROR
               });
            },
            scope: me

        });

        //Use Notifications for Ext errors
        Ext.Error.handle = function(err) {
            PTS.app.showError(err.msg);
        };

        //Handle Ajax exceptions globally
        //TODO: Make Ajax exception handling better, remove redundant code
        Ext.Ajax.on('requestexception',function(conn, response, op){
            var txt = Ext.JSON.decode(response.responseText);

            //set the global app error
            PTS.app.setError(txt.message);
            //only fire the global handler if no failure handler is passed
            //we have to check for regular ajax and data operation callbacks
            if(undefined === op.failure && undefined === op.operation.failure) {
                /*Ext.MessageBox.show({
                   title: 'Error',
                   msg: txt.message,
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   //fn: showResult,
                   icon: Ext.Msg.ERROR
               });*/
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: txt.message
                }).show();
           }
        });

        //add a reference to the app
        PTS.app = this;
    }
});
