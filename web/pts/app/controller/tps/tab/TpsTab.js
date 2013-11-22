/**
 * Controller for TPS Tab
 */
Ext.define('PTS.controller.tps.tab.TpsTab', {
    extend: 'Ext.app.Controller',

    stores: [
        'ModDocTypes',
        'TpsRecords'
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
                //beforerender: this.onBeforeRender,
                render: this.onRender
            }
        });

    },
    
    /**
     * TpsTab render listener. 
     * The tab is masked initially.
     */
    onRender: function(grid) {
        var mask = new Ext.LoadMask(grid, {msg:"Configuring. Please wait..."}),
            grid = this.getTpsGrid(),
            cols = grid.columns,
            docStore = this.getModDocTypesStore();
            
        //load store
        docStore.load({
            callback: function(rec, op, success) {
console.info(arguments);
                if(success) {
                    Ext.each(rec, function(r){
                        cols.push({
                            xtype: 'gridcolumn',
                            dataIndex: 'doctype_' + r.data.moddoctypeid,
                            //flex: 1,
                            text: r.data.code,
                            renderer: PTS.util.Format.docStatus
                        });
                    });
                    
                    grid.reconfigure(false, cols);
                    mask.destroy();
                    grid.getStore().load();
                }
            },
            scope: this
        });
        mask.show();
    }
});
