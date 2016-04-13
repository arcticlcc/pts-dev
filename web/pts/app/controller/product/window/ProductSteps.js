/**
 * The ProductContacts controller
 */
Ext.define('PTS.controller.product.window.ProductSteps', {
    extend: 'Ext.app.Controller',
    requires: [
        'PTS.view.controls.ReorderColumn'
    ],

    views: [
        'product.window.ProductSteps'
    ],
    models: [
        'ProductStep'
    ],
    stores: [
        'ProductSteps',
        'ProductContacts'
    ],
    refs: [{
        ref: 'stepGrid',
        selector: 'productsteps grid'
    }],

    init: function() {

        this.control({
            'productsteps': {
                activate: this.activate,
                beforesaverow: this.updatePriority
            },
            'productsteps grid': {
                beforerender: this.beforeRenderProductStepsList
            },
            'productsteps grid reordercolumn': {
                moverow: this.onReorder
            },
            'productsteps grid > gridview': {
                afterrender: this.afterRenderProductStepsList,
                drop: this.onReorder
            }
        });

        // We listen for the application-wide events
        this.application.on({
            openproduct: this.onOpenProduct,
            scope: this
        });
    },

    /**
     * Set proxy based on current productid.
     * @param {Number} productid
     * @param {PTS.store.ProductContacts}
     */
    setProxy: function(id, store) {

        //override store proxy based on productid
        store.setProxy({
            type: 'rest',
            url: PTS.baseURL + '/productstep',
            appendId: true,
            //batchActions: true,
            api: {
                read: PTS.baseURL + '/product/' + id + '/productstep'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
    },

    /**
     * Open product event.
     */
    onOpenProduct: function(id) {
        var store = this.getProductStepsStore();

        if (id) {
            this.setProxy(id, store);
            //load the store
            store.load();
        }
    },

    /**
     * Handles updating and persisting the step order.
     */
    onReorder: function() {
      var store = this.getProductStepsStore(),
          grid = this.getStepGrid(),
          sm =  grid.getView().getSelectionModel(),
          sel =  sm.getSelection()[0];

      this.updatePriority(null, store);
      store.sync({
        callback: function() {
          if(sel) {
              sm.select(store.indexOfId(sel.getId()), false);
          } else {
              sm.deselectAll();
          }
        }
      });
    },

    /**
     * Stuff to do when Product Steps tab is activated.
     */
    activate: function(tab) {
        var store = tab.down('grid').getStore();

        //load the contact list
        if (store.getCount() === 0) {
            store.load();
        }

    },

    /**
     * Update the step priority based on position.
     */
    updatePriority: function(rec, store) {
        if(rec && rec.phantom) {
            rec.set('priority', store.count());
        } else {
            //loop thru records and set the priority
            store.each(function(itm) {
                var priority = itm.get('priority'),
                    idx = store.indexOf(itm);

                if (priority !== idx) {
                    itm.set('priority', idx);
                }
            });
        }
    },

    /**
     * Configure extra columns, checkboxSelection and reorder.
     * Configure the store
     */
    beforeRenderProductStepsList: function(grid) {
        grid.headerCt.insert(grid.headerCt.getColumnCount() + 1, {
          xtype: 'reordercolumn',
          header: 'Order'
        });
    },

    /**
     * Configure productsteps ddplugin.
     */
    afterRenderProductStepsList: function(view) {
        var plugin = view.getPlugin('stepsddplugin'),
            dropZone = plugin.dropZone;
        dropZone.handleNodeDrop = function(data, record, position) {
            var view = this.view,
                store = view.getStore(),
                index, records;

            /*
             * Remove from the source store. We do this regardless of whether the store
             * is the same because the store currently doesn't handle moving records
             * within the store. In the future it should be possible to do this.
             * Here was pass the isMove parameter if we're moving to the same view.
             */
            data.view.store.remove(data.records, data.view === view);

            index = store.indexOf(record);

            // 'after', or undefined (meaning a drop at index -1 on an empty View)...
            if (position !== 'before') {
                index++;
            }
            store.insert(index, data.records);
            view.getSelectionModel().select(data.records);
        };
    }
});
