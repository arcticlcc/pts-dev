/**
 * Controller for TPS Tab
 */
Ext.define('PTS.controller.tps.tab.TpsTab', {
    extend: 'Ext.app.Controller',

    stores: [
        'ModDocTypes',
        'TpsRecords',
        'ModDocStatusTypes'
    ],
    models: [
        'ModDocType'
    ],
    views: [
        'tps.tab.TpsTab'
    ],

    refs: [{
        ref: 'tpsGrid',
        selector: 'tpstab tpsgrid#tpsGrid'
    }],

    init: function() {
        var grid = this.getController('tps.tab.TpsGrid');

        // Remember to call the init method manually
        grid.init();

        this.control({
            'tpstab': {
                render: this.onRender
            }
        });

    },

    /**
     * TpsTab render listener.
     * The tab is masked initially.
     */
    onRender: function(tab) {
        var mask = new Ext.LoadMask(tab, {
                msg: "Configuring. Please wait..."
            }),
            grid = this.getTpsGrid(),
            cols = grid.columns,
            docStore = this.getModDocTypesStore();

        //load store
        docStore.load({
            callback: function(rec, op, success) {
                if (success) {
                    //create columns
                    Ext.each(rec, function(r) {
                        cols.push({
                            xtype: 'gridcolumn',
                            dataIndex: 'doctype_' + r.data.moddoctypeid,
                            //flex: 1,
                            hidden: Boolean(r.data.inactive),
                            tooltip: r.data.description || r.data.text,
                            text: r.data.code,
                            renderer: PTS.util.Format.docStatus
                        });
                    });

                    //add columns to grid
                    grid.reconfigure(false, cols);
                    mask.destroy();
                    //just select the first cell on load to avoid issues with detailGrid
                    grid.getStore().on('load', function(store, records, success, oper) {
                        if (store.count() > 0) {
                            this.normalGrid.getSelectionModel().setCurrentPosition({
                                row: 0,
                                column: 0
                            });
                        }
                    }, grid);

                    grid.getStore().load();
                }
            },
            scope: this
        });
        mask.show();
    }
});
