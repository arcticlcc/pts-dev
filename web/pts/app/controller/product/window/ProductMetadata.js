/**
 * The ProductMetadata controller
 */
Ext.define('PTS.controller.product.window.ProductMetadata', {
    extend: 'Ext.app.Controller',
    requires: [],
    mixins: {
        fixQuery: 'PTS.util.mixin.FixRemoteQuery'
    },

    views: ['product.window.ProductMetadata'],
    models: ['Product', 'ProductMetadata'],
    stores: ['TopicCategories'],
    refs: [{
        ref: 'productMetadata',
        selector: 'productmetadata'
    },{
        ref: 'metadataForm',
        selector: 'productmetadata productmetadataform'
    }, {
        ref: 'metadataPreview',
        selector: 'productmetadata #metadataPreview'
    }],

    init: function() {

        /*var md = this.getController('product.form.MetadataForm')

         // Remember to call the init method manually
         md.init();*/

        this.control({
            'productmetadata': {
                activate: this.activate
            },
            'productmetadata button[action=goback]': {
                click: this.clickBack
            },
            'productmetadata button[action=openpreview]': {
                click: this.openPreview
            },
            'productmetadata button[action=json]': {
                click: this.clickPreview
            },
            'productmetadata button[action=xml]': {
                click: this.clickPreview
            },
            'productmetadata button[action=html]': {
                click: this.clickPreview
            },
            'productmetadata button[action=reset]': {
                click: this.clickReset
            },
            'productmetadata button[action=save]': {
                click: this.clickSave
            },
            'productmetadata #publishBtn': {
                change: this.publish
            },
            'productmetadata productmetadataform': {
                //broken in 4.0.7
                //dirtychange: this.onDirtyChange,
                validitychange: this.onValidityChange
            },
            'productmetadata productmetadataform combobox[queryMode=remote]': {
                beforequery: this.fixRemoteQuery
            }
        });

        // We listen for the application-wide events
        this.application.on({
            //openproduct: this.onOpenProduct,
            loadproduct: this.onLoadProduct,
            saveproduct: this.onLoadProduct,
            scope: this
        });
    },

    /**
     * Handle productmetadataform validity change event.
     */
    onValidityChange: function(form,valid) {
        var saveBtn = this.getProductMetadata().down('button[action=save]');

        if (valid /*&& form.isDirty()*/) {//dirtychange not working with itemselector in 4.0.7
            saveBtn.enable();
        } else {
            saveBtn.disable();
        }
    },

    /**
     * Handle productmetadataform dirty change event.
     */
    onDirtyChange: function(form,dirty) {
        var saveBtn = this.getProductMetadata().down('button[action=save]'),
            resetBtn = this.getProductMetadata().down('button[action=reset]');

        if (dirty) { //boxselect always reports as dirty after change in 4.0.7
            resetBtn.enable();
            if (form.isValid()) {
                saveBtn.enable();
            }
        } else {
            resetBtn.disable(); //dirtychange not working with itemselector in 4.0.7
            saveBtn.disable();
        }
    },

    /**
     * Load product event.
     */
    onLoadProduct: function(record) {
        var idx = !!(record.get('exportmetadata')) ? 1 : 0,
            btn = this.getProductMetadata().down('#publishBtn'),
            items = btn.menu.items,
            id = record.get('productid'),
            model = this.getProductMetadataModel(),
            form = this.getMetadataForm();

        btn.setActiveItem(items.get(idx), true);

        if(id) {
            form.setLoading(true, true);

            model.load(id, {// load with id from product record
                success: function(model) {
                    form.loadRecord(model);
                }
            });
        }

    },

    /**
     * Stuff to do when Product Metadata tab is activated.
     */
    activate: function(tab) {

    },

    /**
     * Reset button click handler.
     */
    clickReset: function(btn) {
        this.getMetadataForm().getForm().reset();
    },

    /**
     * Save button click handler.
     */
    clickSave: function(btn) {
        var form = this.getMetadataForm().getForm(),
            el = this.getMetadataForm().getEl(),
            record = form.getRecord();

        el.mask('Saving...');
        form.updateRecord(record);
        record.save({
            success: function(model, op) {
                var form = this.getMetadataForm();

                //load the model to get desired trackresetonload behavior
                form.loadRecord(model);
                el.unmask();
            },
            failure: function(model, op) {
                el.unmask();
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'There was an error saving the product metadata.</br>Error: ' + PTS.app.getError()
                }).show();
            },
            scope: this
        });
    },

    /**
     * Back button click handler.
     */
    clickBack: function(btn) {
        this.getProductMetadata().getLayout().setActiveItem(0);
    },

    /**
     * Preview button click handler.
     */
    clickPreview: function(btn) {
        var prev = this.getMetadataPreview(),
            el = prev.getEl(),
            id = prev.up('productwindow').productId,
            tab = this.getProductMetadata(),
            layout = tab.getLayout(),
            openBtn = tab.down('button[action=openpreview]');

        layout.setActiveItem(1);
        layout.getActiveItem().body.scrollTo('top',0);
        el.mask('Generating Preview...');
        //set the preview type
        openBtn.previewType = btn.action;

        el.child('code').load({
            url: '/product/' + id + '/metadata.' + btn.action + '?pretty=1',
            renderer: function(loader, resp) {
                loader.getTarget().update(hljs.highlight(btn.action, resp.responseText).value);
                el.unmask();
            }
        });
    },

    /**
     * Open preview button click handler.
     */
    openPreview: function(btn) {
        var id = btn.up('productwindow').productId;

        window.open('/product/' + id + '/metadata.' + btn.previewType + '?pretty=1', '_blank', null, true);
    },

    /**
     * Publish button click handler.
     */
    publish: function(btn) {
        var win = btn.up('productwindow'),
            record = win.down('productform').getForm().getRecord(),
            action = btn.getActiveItem().action,
            id = win.productId;

        btn.disable();

        Ext.Ajax.request({
            url: '/product/' + id + '/metadata/publish',
            method: action,
            success: function(response, opts) {
                record.set('exportmetadata', action === 'DELETE' ? 0 : 1);
                record.save({
                    failure: function(model, op) {
                        Ext.create('widget.uxNotification', {
                            title: 'Error',
                            iconCls: 'ux-notification-icon-error',
                            html: 'The metadata was ' + action === 'DELETE' ? 'unpublished' : 'published. ' +
                                'However, there was an error saving the product.</br>Error:' + PTS.app.getError()
                        }).show();
                    }
                });

            },
            failure: function(response) {
                var items = btn.menu.items;
                //reset the button
                btn.setActiveItem(items.get(action === 'DELETE' ? 1 : 0), true);
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'There was an error publishing the metadata.</br>Error:' + PTS.app.getError()
                }).show();
            },
            callback: function(response, opts) {
                btn.enable();
            }
        });

    }
});
