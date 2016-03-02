/**
 * Main Controller for app setup
 */
Ext.define('PTS.controller.Main', {
    extend: 'Ext.app.Controller',

    init: function() {
        console.info('main');
        var me = this,
            task,
            //myMask = new Ext.LoadMask(Ext.getBody(), {msg:"Please wait...Fetching User Info"}),
            body = Ext.getBody(),
            removeMask = function() {
                if (!Ext.Ajax.isLoading()) {
                    //myMask.destroy();
                    body.unmask();
                    Ext.Ajax.un('requestcomplete', removeMask, me);
                }
            };

        //remove the mask after initial requests are complete
        Ext.Ajax.on('requestcomplete', removeMask, me, {
            buffer: 200
        });

        //myMask.show();
        body.mask('Please wait...Fetching User Info'); //mask the window body

        //get user details
        me.getModel('PTS.model.User').load(PTS.UserId.id, {

            success: function(user) {
                var store = this.getStore('GroupUsers'),
                    group = user.get('groupid');

                PTS.user = user; //save user details
                PTS.orgcode = PTS.user.get('acronym'); //set orgcode

                PTS.userConfig = Ext.create('PTS.model.UserConfig', user.get('config'));

                //set store page size
                var pageSize = PTS.userConfig.get('pageSize');
                PTS.Defaults.pageSize = pageSize ? pageSize : PTS.Defaults.pageSize;
                Ext.StoreManager.each(function(store) {
                  if(store.pageSize === 25) {
                    store.pageSize = PTS.Defaults.pageSize;
                  }
                });

                //set the GroupUsers proxy using the PTS.user groupid
                store.setProxy({
                    type: 'ajax',
                    url: PTS.baseURL + '/contactgroup/' + group + '/person',
                    reader: {
                        type: 'json',
                        root: 'data'
                    },
                    //For ALCC, we only want staff not SC members
                    extraParams: {
                        filter: Ext.encode([{
                            property: 'positionid',
                            value: ['where not in', [96, 85]]
                        }])
                    }
                });

                store.load({
                    callback: function(rec, op, success) {
                        if (success) {
                            //add system account to store
                            this.loadRawData([{
                                "contactid": 0,
                                "firstname": "System",
                                "lastname": "PTS",
                                "groupid": group,
                                "inactive": true
                            }], true);
                        }
                    },
                    scope: store
                });

                body.mask('Please wait...Fetching Data'); //update mask
                //load ProjectID store
                me.getStore('ProjectIDs').load();

                Ext.create('PTS.view.Viewport');

                //setup activity monitor
                PTS.util.ActivityMonitor.init({
                    verbose: false,
                    interval: (1000 * 900 * 1), //15 minutes
                    maxInactive: (1000 * 13470 * 1), //224.5 minutes
                    isActive: function() {
                        Ext.Ajax.request({
                            url: PTS.baseURL + '/poll'
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
                            run: function() {
                                win.seconds += 1;
                                if (win.seconds > 6) {
                                    Ext.TaskManager.stop(win.task);
                                    window.location = PTS.baseURL + '/logout'; //logout
                                } else {
                                    win.updateProgress(win.seconds / 6);
                                }
                            },
                            scope: this,
                            interval: (1000 * 2) //ten seconds
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
                    msg: 'There was an error. Failed to retrieve user info.',
                    buttons: Ext.MessageBox.OK,
                    //animateTarget: 'mb9',
                    //fn: showResult,
                    icon: Ext.Msg.ERROR
                });
            },
            scope: me

        });
    }
});
