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
            'tasklist button[action=togglecomplete]': {
                toggle: this.toggleComplete
            },
            'tasklist button[action=filtertask]': {
                change: this.filterTask
            }
        });
    },

    /**
     * @cfg {Boolean} showComplete
     * @private
     */

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

        switch (itm.filter) {
            case 'user':
                store.filters.add(new Ext.util.Filter({
                    property: 'contactid',
                    value: PTS.user.get('contactid')
                }));
                break;
            case 'today':
                dt = new Date();
                store.filters.add(new Ext.util.Filter({
                    property: 'duedate',
                    value: Ext.Date.clearTime(dt)
                }));
                break;
            default:
                store.clearFilter();
        }

        if (!this.showComplete) {
            store.filters.add(new Ext.util.Filter({
                property: 'completed',
                value: 'false'
            }));
        }

        store.load();
    },

    /**
     * Filter the task list
     * @param {Ext.button.Button} btn The button
     * @param {Ext.menu.CheckItem} pressed The pressed state
     */
    toggleComplete: function(btn, pressed) {
        var store = this.getTasksStore(),
            filters = store.filters;
        //idx = store.filters.findIndex('property','completed'),
        //filter = store.filters.getAt(idx);

        this.showComplete = pressed;
        if (pressed) {
            filters.removeAt(filters.findIndex('property', 'completed'));
        } else {
            filters.add(new Ext.util.Filter({
                property: 'completed',
                value: 'false'
            }));
        }
        store.load();
    }
});
