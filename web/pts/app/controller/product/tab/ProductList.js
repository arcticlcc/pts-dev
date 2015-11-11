/**
 * Controller for ProductList
 */
Ext.define('PTS.controller.product.tab.ProductList', {
    extend: 'Ext.app.Controller',
    stores: [
        'Products',
        'ProjectIDs'
    ],
    models: [
        'Product'
    ],
    views: [
        'product.tab.ProductList'
    ],
    refs: [{
        ref: 'productList',
        selector: 'producttab > productlist'
    }],

    init: function() {

        this.control({
            'productlist': {
                itemdblclick: this.editProduct,
                viewready: this.onProductListReady,
                select: this.onProductListSelect
            }
        });

        // We listen for the application-wide events
        this.application.on({
            saveproduct: this.onSaveProduct,
            deleteproduct: this.onDeleteProduct,
            scope: this
        });
    },

    editProduct: function(grid, record) {
        var pc = this.getController('product.Product');

        pc.openProduct(record);
    },

    onProductListReady: function(grid) {
        var store = grid.getStore();
        if (store) {
            store.on('load', function(store, records, success, oper) {
                if (store.count() > 0) {
                    this.getSelectionModel().select(0);
                }
            }, grid);
        }
        store.load();
    },

    onProductListSelect: function(rowModel, record) {
        this.application.fireEvent('productlistselect', record);
    },

    onSaveProduct: function(record, op) {
        var index,
            copy,
            store = this.getProductsStore(),
            model = this.getProductModel(),
            id = record.getId(),
            pid = record.get('projectid');

        index = store.indexOfId(id);

        if (index === -1) {
            //The record is new, refresh to update the "related" fields
            copy = Ext.create(model);
            store.insert(0, copy);
        } else {
            //The record exists in the store, so copy the data
            //Note: this will only copy the "product" fields,
            //refresh to update the "related" fields
            copy = store.getAt(index);
        }

        copy.fields.each(function(field) {
            copy.set(field.name, record.get(field.name));
        });

        //set projectcode
        copy.set('projectcode', this.getProjectIDsStore().getById(pid).get('projectcode'));
        copy.commit();
    },

    /**
     * Fired when a product is deleted.
     * No record is passed(null), so we
     * need to use the operation records array
     */
    onDeleteProduct: function(record, op) {
        var store = this.getProductsStore();

        Ext.each(op.records, function(rec) {
            var id = rec.getId();

            store.remove(store.getById(id));
        });
    }
});
