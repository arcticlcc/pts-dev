/**
 * Controller for ProductTab
 */
Ext.define('PTS.controller.product.tab.ProductTab', {
    extend: 'Ext.app.Controller',

    views: [
        'product.tab.ProductTab'
    ],

    refs: [{
        ref: 'productList',
        selector: 'producttab > productlist'
    },{
        ref: 'productTab',
        selector: 'producttab'
    }],

    init: function() {

        var list = this.getController('product.tab.ProductList');//,
            //det = this.getController('product.tab.ProductDetail');

        // Remember to call the init method manually
        list.init();
        //det.init();

        this.control({
            'producttab button[action=addproduct]': {
                click: this.newProduct
            },

            'producttab button[action=editproduct]': {
                click: this.editProduct
            }
        });

        // We listen for the application-wide productlistselect event
        this.application.on({
            productlistselect: this.onProductListSelect,
            scope: this
        });
    },

    newProduct: function() {
        var pc = this.getController('product.Product');
        pc.openProduct();
    },

    editProduct: function() {
        var pc = this.getController('product.Product'),
            record = this.getProductList().getSelectionModel().getSelection()[0];
        if(record) {
            pc.openProduct(record);
        }
    },

    onProductListSelect: function(prd) {
            this.getProductTab().down('button[action=editproduct]').setDisabled(!prd);
    }
});
