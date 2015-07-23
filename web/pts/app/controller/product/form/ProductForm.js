/**
 * Product Form controller.
 */
Ext.define('PTS.controller.product.form.ProductForm', {
    extend: 'Ext.app.Controller',
    mixins: {
        fixQuery: 'PTS.util.mixin.FixRemoteQuery'
    },

    views: [
        'product.form.ProductForm'
    ],
    models: [
        'Product'
    ],
    stores: [
        'ProjectIDs',
        'IsoProgressTypes'
    ],
    refs: [{
        ref: 'productForm',
        selector: 'productform'
    }],

    init: function() {

        /*var list = this.getController('product.tab.ProductList')

        // Remember to call the init method manually
        list.init();*/

        this.control({
            'productform button[action=saveproduct]': {
                click: this.saveProduct
            },
            'productform button[action=resetproduct]': {
                click: this.resetProduct
            },
            'productform button[action=deleteproduct]': {
                click: this.confirmDelete
            },
            'productform combobox[queryMode=remote]': {
                beforequery: this.fixRemoteQuery
            }
        });

        // We listen for the application-wide openproduct event
        this.application.on({
            openproduct: this.onOpenProduct,
            scope: this
        });
    },

    /**
     * Open product event.
     * TODO: filter parent productlist to remove current product
     */
    onOpenProduct: function(id) {
        this.loadRecord(id);
    },

    /**
     * Load product event.
     */
    onLoadProduct: function(record) {
        this.application.fireEvent('loadproduct', record);
    },

    /**
     * Save product event.
     */
    onSaveProduct: function(record, op) {
        this.application.fireEvent('saveproduct', record, op);
    },

    /**
     * Delete product event.
     */
    onDeleteProduct: function(record, op) {
        this.application.fireEvent('deleteproduct', record, op);
    },

    //TODO: fire app events to relod product list, etc.
    /**
     * Save product.
     */
     saveProduct: function() {
        var form = this.getProductForm().getForm(),
            el = this.getProductForm().getEl(),
            record = form.getRecord();

        el.mask('Saving...');
        form.updateRecord(record);
        record.save({
            success: function(model, op) {
                var form = this.getProductForm();

                form.loadRecord(model); //load the model to get desired trackresetonload behaviour
                form.up('window').productId = model.getId();
                el.unmask();

                this.onSaveProduct(model, op);
            },
            failure: function(model, op) {
                el.unmask();
                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'There was an error saving the product.</br>Error:' + PTS.app.getError(),
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   //fn: showResult,
                   icon: Ext.Msg.ERROR
               });
            },
            scope: this //need the controller to load the model on success
        });
     },

    /**
     * Confirm product deletion.
     */
    confirmDelete: function(btn) {
        var el = btn.getEl(),
            del = function(b) {
                if('yes' === b) {
                    this.deleteProduct();
                }
            };

        Ext.MessageBox.show({
            title: 'Confirm Deletion',
            msg: 'Are you sure you want to delete this product?',
            //width:300,
            buttons: Ext.MessageBox.YESNO,
            icon: Ext.Msg.WARNING,
            fn: del,
            scope: this,
            animateTarget: el
        });
    },

    /**
     * Delete product.
     */
     deleteProduct: function() {
        var form = this.getProductForm().getForm(),
            el = this.getProductForm().getEl(),
            record = form.getRecord();

        el.mask('Deleting...');
        record.destroy({
            success: function(model, op) {
                el.unmask();
                this.onDeleteProduct(model, op);
                this.getProductForm().up('window').close();
            },
            failure: function(model, op) {
                el.unmask();
                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'There was an error deleting the product.</br>Error:' + PTS.app.getError(),
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   icon: Ext.Msg.ERROR
               });
            },
            scope: this //need the controller
        });
     },

    /**
     * Reset product form.
     */
     resetProduct: function() {
        var form = this.getProductForm().getForm();

        form.reset();
     },

    /**
     * Load product.
     */
    loadRecord: function(id) {
        var ctl = this,
            model = this.getProductModel(),
            form = this.getProductForm();

        if(id) {
            model.load(id, { // load with id from selected record
                success: function(model) {
                    form.loadRecord(model); // when model is loaded successfully, load the data into the form

                    /*Ext.each(itemCard.query('field'), function() {// set all fields as read-only on load
                        this.setReadOnly(true);
                    });
                    itemDetail.setIconCls('alcc-panel-locked');//set the lock icon on the panel

                    Ext.each(btns, function(){
                        this.enable();
                    });
                    itemDetail.getLayout().setActiveItem(itemCard);
                    if(itemCard.isXType('form')) {
                        //console.info(itemCard.xtype);
                        if(itemCard.getForm().isDirty()) {
                            reset.enable();
                            if(itemCard.getForm().isValid()) {
                                save.enable();
                            }
                        } else {
                            reset.disable();
                            save.disable();
                        }
                    }
                    itemDetail.setTitle(rec.get('type') + ": " + rec.get('task'));
                    itemDetail.enable();*/
                    ctl.onLoadProduct(model);
                },
                failure: function(model, op) {
                    Ext.MessageBox.show({
                       title: 'Error',
                       msg: 'There was an error loading the product.</br>Error:' + PTS.app.getError(),
                       buttons: Ext.MessageBox.OK,
                       //animateTarget: 'mb9',
                       icon: Ext.Msg.ERROR
                   });
                }
            });
        } else{
            form.loadRecord(Ext.create(model));
            ctl.onLoadProduct(form.getForm().getRecord());
        }
    }
});
