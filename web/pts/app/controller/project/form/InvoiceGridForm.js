/**
 * Controller for InvoiceGridForm
 */
Ext.define('PTS.controller.project.form.InvoiceGridForm', {
    extend: 'Ext.app.Controller',

    views: [
        'project.form.InvoiceGridForm'
    ],
    models: [
        'Invoice'
    ],
    stores: [
        'ProjectContacts',
        'ProjectInvoicers',
        'Invoices',
        'CostCodeInvoices',
        'CostCodes'
    ],
    refs: [{
        ref: 'invoiceGridForm',
        selector: 'invoicegridform'
    },{
        ref: 'invoiceList',
        selector: 'invoicegridform>#invoiceList'
    },{
        ref: 'invoiceForm',
        selector: 'invoicegridform>#invoiceForm'
    },{
        ref: 'fundingForm',
        selector: 'fundingform>form'
    }],

    init: function() {
        this.control({
            'invoicegridform>#invoiceList': {
                selectionchange: this.onInvoiceSelection,
                itemdblclick: this.onDblClickInvoice
            },
            '#invoiceList button[action=editinvoice]': {
                click: this.editInvoiceHandler
            },
            '#invoiceList button[action=addinvoice]': {
                click: this.addInvoice
            },
            '#invoiceForm button[action=saveinvoice]': {
                click: this.saveInvoice
            },
            '#invoiceForm button[action=deleteinvoice]': {
                click: this.deleteInvoice
            },
            '#invoiceForm button[action=resetinvoice]': {
                click: this.resetInvoice
            },
            '#invoiceForm button[action=showlist]': {
                click: this.showInvoiceList
            }
        });

        /*// We listen for the application-wide openproject event
        this.application.on({
            openproject: this.onOpenProject,
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });*/
    },

    /**
     * Update status of the editinvoice button.
     */
    onInvoiceSelection: function(sm, sel) {
        var btn = this.getInvoiceGridForm().down('#invoiceList button[action=editinvoice]');

        btn.setDisabled(!sm.getCount());
    },

    /**
     * Set the active card to the invoicelist.
     */
    showInvoiceList: function() {
        this.getInvoiceGridForm().getLayout().setActiveItem('invoiceList');
    },

    /**
     * Handler for the editinvoice button.
     */
    editInvoiceHandler: function() {
        var rec = this.getInvoiceList().getSelectionModel().getSelection()[0];

        this.editInvoice(rec);
    },

    /**
     * Reset the invoice form.
     */
    resetInvoice: function(){
        this.getInvoiceForm().getForm().reset();
    },

    /**
     * Handler for invoicelist double-clicks.
     */
    onDblClickInvoice: function(grid, rec) {
        this.editInvoice(rec);
    },

    /**
     * Edit invoice.
     * @param PTS.model.Invoice rec The invoice record to be edited
     */
    editInvoice: function(rec) {
        var fundingid,
            invForm = this.getInvoiceForm(),
            ccStore = this.getCostCodesStore(),
            ccGrid;

        //load the funding costcodes if not loaded
        //TODO: create method for this, see also #addInvoice
        if(!ccStore.count()) {
            if(!ccStore.isLoading() && ccStore.count() === 0) {
                ccGrid = invForm.down('roweditgrid#costCodes');
                ccGrid.getEl().mask('Loading...');
                fundingid = invForm.up('fundingform').down('#itemForm').getRecord().getId();
                this.getController('project.form.FundingForm').updateDetailStore(ccStore, fundingid, 'costcode');
                ccStore.load(function(records, operation, success) {
                    ccGrid.getView().refresh();
                    ccGrid.getEl().unmask();
                });
            }
        }

        //load the record and bind the costcode store
        invForm.loadRecord(rec);
        invForm.down('roweditgrid#costCodes').bindStore(rec.costcodes());

        this.getInvoiceGridForm().getLayout().setActiveItem(1);
    },

    /**
     * Add invoice
     */
    addInvoice: function() {
        var fundingid,
            invForm = this.getInvoiceForm(),
            ccStore = this.getCostCodesStore(),
            ccGrid,
            rec = Ext.create(this.getInvoiceModel());

        //load the funding costcodes if not loaded
        if(!ccStore.count()) {
            if(!ccStore.isLoading() && ccStore.count() === 0) {
                ccGrid = invForm.down('roweditgrid#costCodes');
                ccGrid.getEl().mask('Loading...');
                fundingid = invForm.up('fundingform').down('#itemForm').getRecord().getId();
                this.getController('project.form.FundingForm').updateDetailStore(ccStore, fundingid, 'costcode');
                ccStore.load(function(records, operation, success) {
                    ccGrid.getView().refresh();
                    ccGrid.getEl().unmask();
                });
            }
        }

        //load the record and bind the costcode store
        invForm.loadRecord(rec);
        invForm.down('roweditgrid#costCodes').bindStore(rec.costcodes());

        this.getInvoiceGridForm().getLayout().setActiveItem(1);
    },

    /**
     * Save invoice.
     */
     saveInvoice: function() {
        var panel = this.getInvoiceForm(),
            form = panel.getForm(),
            record = form.getRecord(),
            fid = this.getFundingForm().getRecord().getId();
            //store;

        //mask the form
        panel.getEl().mask('Loading...');
        //set the fundingid
        record.set('fundingid',fid);
        //update the record
        form.updateRecord(record);

        record.save({
            success: function(model, op) {
                var listStore = this.getInvoicesStore(),
                    idx = listStore.indexOfId(model.getId());


                form.loadRecord(model); //load the model
                panel.down('roweditgrid#costCodes').bindStore(model.costcodes());//bind the new associated store
                //reset all the original values to get desired trackresetonload behaviour
                Ext.each(panel.query('field'), function() {
                    this.resetOriginalValue();
                });
                //if the record is in the invoicelist replace it
                if( idx !== -1) {
                    listStore.removeAt(idx);
                    listStore.insert(idx, model);
                } else {//add it
                    listStore.add(model);
                }

                panel.getEl().unmask();
            },
            failure: function(model, op) {
                //TODO: clean out phantom associated records to prevent duplicates
                /*if(record.associations.items.length) {//check for associations
                    //loop thru associations
                    record.associations.each(function(assoc){
                        var store = record[assoc.name]();
                        //and get phantom records
                        store.remove(store.getNewRecords());
                    },this);
                }*/

                //panel.getEl().unmask();

                Ext.MessageBox.show({
                    title: 'Error',
                    msg: 'There was a problem saving the invoice.</br>' + PTS.app.getError(),
                    buttons: Ext.MessageBox.OK,
                    animateTarget: panel.down('button[action=saveinvoice]').getEl(),
                    fn: function() {
                        panel.getEl().unmask();
                    },
                    icon: Ext.Msg.ERROR
               });
            },
            scope: this //need the controller to load the model on success
        });
     },

    /**
     * Delete invoice.
     */
     deleteInvoice: function() {
        var panel = this.getInvoiceForm(),
            form = panel.getForm(),
            record = form.getRecord();

        //mask the form
        panel.getEl().mask('Loading...');

        record.destroy({
            success: function(model, op) {
                var listStore = this.getInvoicesStore(),
                    idx = listStore.indexOfId(record.getId());

                //if the record is in the invoicelist replace it
                if( idx !== -1) {
                    listStore.removeAt(idx);
                }
                panel.getEl().unmask();
                this.getInvoiceGridForm().getLayout().setActiveItem('invoiceList');
            },
            failure: function(model, op) {

                Ext.MessageBox.show({
                    title: 'Error',
                    msg: 'There was a problem deleting the invoice.</br>' + PTS.app.getError(),
                    buttons: Ext.MessageBox.OK,
                    animateTarget: panel.down('button[action=deleteinvoice]').getEl(),
                    fn: function() {
                         panel.getEl().unmask();
                    },
                    icon: Ext.Msg.ERROR
               });
            },
            scope: this
        });
     }
});
