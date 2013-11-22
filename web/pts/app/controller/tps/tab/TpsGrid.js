/**
 * Controller for TPS Grid
 */
Ext.define('PTS.controller.tps.tab.TpsGrid', {
    extend: 'Ext.app.Controller',

    stores: [        
        'ModDocTypes'
    ],
    models: [
        //'ModDocType'
    ],
    views: [
        'tps.tab.TpsGrid'
    ],

    /*refs: [{
        ref: 'reportTree',
        selector: 'reporttab #reportTree'
    },{
        ref: 'reportPanel',
        selector: 'reporttab #reportPanel'
    },{
        ref: 'helpTab',
        selector: 'reporttab #helpTab'
    }],*/

    init: function() {

        this.control({
            'tpstab tpsgrid#tpsGrid': {
                beforerender: this.onBeforeRender
            }
        });

    },
    
    /**
     * TpsGrid beforerender listener. 
     * Configure the grid columns and load the data store.
     */
    onBeforeRender: function(grid) {
        //return false;
    }    
});
