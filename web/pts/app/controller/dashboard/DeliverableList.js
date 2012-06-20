/**
 * @class PTS.controller.dashboard.DeliverableList
 */
Ext.define('PTS.controller.dashboard.DeliverableList', {
    extend: 'Ext.app.Controller',
    stores: ['DeliverableListings'],
    views: [
        'dashboard.DeliverableList'
    ],

    init: function() {

        this.control({
            'deliverablelist button[action=filterdeliverable]': {
                change: this.filterDeliverable
            }
        });
    },

    /**
     * Filter the deliverable list
     * @param {Ext.button.Cycle} btn The cycle button
     * @param {Ext.menu.CheckItem} item The menu item that was selected
     */
    filterDeliverable: function(btn, itm) {
        var store = this.getDeliverableListingsStore(),
            dt;

        //TODO: Fixed in 4.1?
        //http://www.sencha.com/forum/showthread.php?139210-3461-ExtJS4-store-suspendEvents-clearFilter-problem
        store.remoteFilter = false;
        store.clearFilter(true);
        store.remoteFilter = true;

        switch(itm.filter) {
            case 'over':
                store.filter([
                    {
                        property: 'dayspastdue',
                        value   : ['>',0]
                    },
                    {
                        property: 'receiveddate',
                        value   : ['null']
                    }
                ]);
                break;
            case 'soon':
                store.filter([
                    {
                        property: 'dayspastdue',
                        value   : ['<=',0]
                    },
                    {
                        property: 'dayspastdue',
                        value   : ['>',-30]
                    },
                    {
                        property: 'receiveddate',
                        value   : ['null']
                    }
                ]);
                break;
            case 'complete':
                store.filter([
                    {
                        property: 'receiveddate',
                        value   : ['not null']
                    }
                ]);
                break;
            default:
                store.clearFilter();
        }
    }
});