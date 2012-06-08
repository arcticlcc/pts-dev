/**
 * @class PTS.controller.dashboard.Dashboard
 */
Ext.define('PTS.controller.dashboard.Dashboard', {
    extend: 'Ext.app.Controller',
    //requires: ['Extensible.Extensible'],

    views: [
        'dashboard.Dashboard'
    ],

    init: function() {

        var cal = this.getController('dashboard.Calendar'),
        task = this.getController('dashboard.TaskList'),
        del = this.getController('dashboard.DeliverableList');

        // Remember to call the init method manually
        cal.init();
        task.init();
        del.init();

        /*this.control({
            'userlist': {
                itemdblclick: this.editUser
            }
        });*/
    }
});
