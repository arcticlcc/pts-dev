/**
 * Controller for Deliverable Form
 */
Ext.define('PTS.controller.project.form.DeliverableForm', {
    extend: 'Ext.app.Controller',

    views: [
        'project.form.DeliverableForm'
    ],
    models: [
        'DeliverableType'
    ],
    stores: [
        'DeliverableTypes',
        'DeliverableComments'
    ],
    refs: [{
        ref: 'deliverableForm',
        selector: 'deliverableform#itemCard-30 #itemForm'
    },{
        ref: 'deliverableCard',
        selector: 'deliverableform#itemCard-30'
    }],

    init: function() {
        this.control({
            'deliverableform#itemCard-30 #relatedDetails>roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            }
        });

        // We listen for application-wide events
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });
    },

    /**
     * Disable the related details panel and clear any related grid stores.
     */
    onNewItem: function(model, form) {
        //we have to check the itemId
        if(this.getDeliverableCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid');

            form.ownerCt.down('#relatedDetails').disable();
            Ext.each(grids, function(gr){
                gr.getStore().removeAll();
            });
        }
    },

    /**
     * Check to see if this is a mod and set field write permissions.
     * Load the active roweditgrid, if any. Clear the other stores.
     * TODO: probably should use associations for this
     */
    onItemLoad: function(model, form) {
        var con,
            mod = !!model.get('parentdeliverableid');

        if(Ext.getClassName(model) === "PTS.model.Deliverable") {
            con = this.getDeliverableForm().down('#mainCon');

            con.items.each(function(itm) {
                itm.doNotEnable = mod ? true : false;
                //reset the opacity, set when edit button is clicked
                itm.getEl().setOpacity(1);
            });

        }

        //we have to check the itemId
        if(this.getDeliverableCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid'),
                id = model.get('deliverableid');

            Ext.each(grids,function(gr){
                var store = gr.getStore(),
                    active = gr.tab === undefined ? gr.ownerCt.tab.active : gr.tab.active; //check the tab status

                if(active) {
                    this.updateDetailStore(store, id, gr.uri);
                    store.load({
                        callback: function(rec, op, success) {
                            if(success) {
                                gr.up('#relatedDetails').enable();
                            }
                        },
                        scope: gr
                    });
                }else {
                    store.removeAll();
                }
            }, this);
        }
    },

    /**
     * Update the record in the roweditgrid store with the deliverableid.
     */
    onDetailRowEdit: function(editor, e) {
        var model = this.getDeliverableForm().getRecord(),
            id = model.get('deliverableid');

        editor.record.set('deliverableid',id);
        editor.store.sync();

    },

    /**
     * Update the activated roweditgrid store with current the deliverableid.
     */
    onDetailActivate: function(grid) {
        var model = this.getDeliverableForm().getRecord(),
            store, id;

        if(model !== undefined) {
            store = grid.getStore();
            //only load if the store is not loading
            if(!store.isLoading() && store.count() === 0) {
                id = model.get('deliverableid');
                this.updateDetailStore(store, id, grid.uri);
                store.load();
            }
        }
    },

    /**
     * Update the roweditgrid store with the passed deliverableid.
     */
    updateDetailStore: function(store, id, uri) {

        //override store proxy based on deliverableid
        store.setProxy({
            type: 'rest',
            url : '../'+ uri,
            //appendId: true,
            api: {
                read:'../deliverable/' + id + '/' + uri
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
    }
});
