/**
 * Main Product controller
 */
Ext.define('PTS.controller.product.Product', {
    extend: 'Ext.app.Controller',
    /*requires: [
        'PTS.model.OnlineResource'
    ],*/
    views: [
        'product.window.Window'
    ],
    refs: [{
        ref: 'productWindow',
        selector: 'productwindow'
    }],
    stores: [
        //'ProductVectors',
    ],

    init: function() {
        var tab = this.getController('product.tab.ProductTab'),
            win = this.getController('product.window.Window');

        // Remember to call the init method manually
        tab.init();
        win.init();

        // We listen for the application-wide events
        this.application.on({
            saveproduct: this.onSaveProduct,
            scope: this
        });

    },

    /**
     * Updates child proxies.
     * @param {String|Number} The id to use.
     */
    setProxies: function(id) {
        var win = this.getProductWindow();

        //load the product links
        var cstore = win.down('productlinks>gridpanel').getStore();
        cstore.setProxy({
            type: 'rest',
            url : '../onlineresource',
            appendId: true,
            api: {
                read:'../product/' + id + '/onlineresource'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
        cstore.load();
        //load the product statuses
        cstore = win.down('#producttabpanel>productstatus').getStore();
        cstore.setProxy({
            type: 'rest',
            url : '../productstatus',
            appendId: true,
            api: {
                read:'../product/' + id + '/productstatus'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
        cstore.load();
        //load the product comments
        /*cstore = win.down('#producttabpanel>commenteditgrid').getStore();
        cstore.setProxy({
            type: 'rest',
            url : '../productcomment',
            appendId: true,
            api: {
                read:'../product/' + id + '/productcomment'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
        cstore.load();*/
    },
    /**
     * Creates and opens the product window.
     * @param {Object} [record] An optional product record.
     */
    openProduct: function(record, callBack, animateTarget) {
        var win, code, cstore,
            id = record ? record.get('productid') : false;

        if(id !== false) {
            code = record.get('title');

            win = Ext.create(this.getProductWindowWindowView(),{
                title: 'Edit Product: ' + code,
                productId: id
            });

            this.setProxies(id);

        } else{
            win = Ext.create(this.getProductWindowWindowView(),{
                title: 'New Product'
            });
            //disable all tabs except productform
            win.down('#producttabpanel').items.each(function() {
                if('productform' !== this.getXType()) {
                    this.disable();
                }
            });

        }
        this.application.fireEvent('openproduct', id);
        win.show(animateTarget, callBack);
    },

    /**
     * Save product event.
     * Enable all tab panels
     */
    onSaveProduct: function(record) {
        var win = this.getProductWindow();
        //TODO: we could check whether record is a phantom and not perform unnecessary enables
        //enable all tabs except productform, which should already be enabled
        win.down('#producttabpanel').items.each(function() {
            if('productform' !== this.getXType()) {
                this.enable();
            }
        });

        this.setProxies(record.getId());
    }
});
