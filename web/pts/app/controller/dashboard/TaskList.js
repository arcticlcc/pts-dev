/**
 * @class PTS.controller.dashboard.TaskList
 */
Ext.define('PTS.controller.dashboard.TaskList', {
    extend: 'Ext.app.Controller',
    stores: ['Tasks'],
    views: [
        'dashboard.TaskList'
    ],

    init: function() {

        this.control({
            'tasklist button[action=filtertask]': {
                change: this.filterTask
            }
        });
    },

    /**
     * Filter the task list
     * @param {Ext.button.Cycle} btn The cycle button
     * @param {Ext.menu.CheckItem} item The menu item that was selected
     */
    filterTask: function(btn, itm) {
        var store = this.getTasksStore(),
            dt;

        //TODO: Fixed in 4.1?
        //http://www.sencha.com/forum/showthread.php?139210-3461-ExtJS4-store-suspendEvents-clearFilter-problem
        store.remoteFilter = false;
        store.clearFilter(true);
        store.remoteFilter = true;

        switch(itm.filter) {
            case 'user':
                store.filter('contactid',PTS.user.get('contactid'));
                break;
            case 'today':
                dt = new Date();
                store.filter('duedate',(Ext.Date.clearTime(dt)));
                break;
            default:
                store.clearFilter();
        }
    }
});
