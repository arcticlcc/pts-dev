/**
 * Controller for Funding Form
 */
Ext.define('PTS.controller.project.form.FundingForm', {
    extend: 'Ext.app.Controller',

    views: [
        'project.form.FundingForm'
    ],
    /*models: [
        'FundingType'
    ],*/
    stores: [
        'FundingTypes',
        'ProjectFunders',
        'CostCodes',
        'ContactCostCodes',
        'FundingComments',
        'ProjectRecipients'
    ],
    refs: [{
        ref: 'fundingForm',
        selector: 'fundingform>form'
    }, {
        ref: 'fundingCard',
        selector: 'fundingform'
    }],

    init: function() {
        var tab = this.getController('project.form.InvoiceGridForm');

        // Remember to call the init method manually
        tab.init();

        this.control({
            'fundingform #relatedDetails>roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            },
            'fundingform #relatedDetails invoicegridform': {
                activate: this.onInvoiceActivate
            }
        });

        // We listen for the application-wide openproject event
        this.application.on({
            openproject: this.onOpenProject,
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });
    },

    /**
     * Open project event.
     */
    onOpenProject: function(id) {
        var store = this.getProjectFundersStore();

        store.setProxy({
            type: 'rest',
            url: PTS.baseURL + '/projectfunder',
            appendId: true,
            //batchActions: true,
            api: {
                read: PTS.baseURL + '/project/' + id + '/funder'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });

    },

    /**
     * Disable the related details panel and clear any related grid stores.
     */
    onNewItem: function(model, form) {
        //we have to check the itemId
        if (this.getFundingCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid, #relatedDetails invoicegridform #invoiceList'),
                store = this.getProjectRecipientsStore();

            form.ownerCt.down('#relatedDetails').disable();
            Ext.each(grids, function(gr) {
                gr.getStore().removeAll();
            });
            //Check the ProjectRecipients store
            if (store.count() === 1) {
                //set the Project Recipient combo
                this.getFundingForm().down('combo#recipientCombo').setValue(store.getAt(0).getId());
            }
        }
    },

    /**
     * Load the active roweditgrid, if any. Clear the other stores.
     * TODO: probably should use associations for this
     */
    onItemLoad: function(model, form) {
        //we have to check the itemId
        if (this.getFundingCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid,#relatedDetails invoicegridform #invoiceList'),
                id = model.getId(),
                inv = form.ownerCt.down('invoicegridform');

            Ext.each(grids, function(gr) {
                var store = gr.getStore(),
                    active = gr.tab === undefined ? gr.ownerCt.tab.active : gr.tab.active; //check the tab status

                if (active) {
                    this.updateDetailStore(store, id, gr.uri);
                    store.load({
                        callback: function(rec, op, success) {
                            if (success) {
                                gr.up('#relatedDetails').enable();
                            }
                        },
                        scope: gr
                    });
                } else {
                    store.removeAll();
                }
            }, this);
            //reset the invoice card panel
            if (inv.rendered) {
                inv.getLayout().setActiveItem(0);
            }
        }

    },

    /**
     * Update the record in the roweditgrid store with the fundingid.
     */
    onDetailRowEdit: function(editor, e) {
        var model = this.getFundingForm().getRecord(),
            id = model.getId();

        editor.record.set('fundingid', id);
        editor.store.sync();

    },

    /**
     * Update the activated roweditgrid store with current the fundingid.
     */
    onDetailActivate: function(grid) {
        var model = this.getFundingForm().getRecord(),
            store, id;

        if (model !== undefined) {
            store = grid.getStore();
            //only load if the store is not loading
            if (!store.isLoading() && store.count() === 0) {
                id = model.getId();
                this.updateDetailStore(store, id, grid.uri);
                store.load();
            }
        }
    },

    /**
     * Update the activated roweditgrid store with current the fundingid.
     */
    onInvoiceActivate: function(card) {
        var grid = card.down('#invoiceList');

        this.onDetailActivate(grid);
    },

    /**
     * Update the roweditgrid store with the passed fundingid.
     */
    updateDetailStore: function(store, id, uri) {

        //override store proxy based on fundingid
        store.setProxy({
            type: 'rest',
            url: PTS.baseURL + '/' + uri,
            //appendId: true,
            api: {
                read: PTS.baseURL + '/funding/' + id + '/' + uri
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
    }
});
