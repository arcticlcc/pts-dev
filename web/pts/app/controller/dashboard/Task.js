/**
 * @class PTS.controller.dashboard.Task
 */
Ext.define('PTS.controller.dashboard.Task', {
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
