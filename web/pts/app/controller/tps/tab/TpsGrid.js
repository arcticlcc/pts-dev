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

    refs: [{
        ref: 'tpsGrid',
        selector: 'tpstab tpsgrid#tpsGrid'
    }],

    init: function() {

        this.control({
            'tpstab tpsgrid#tpsGrid': {
                afterrender: this.onAfterRender
            }
        });

    },
    
    /**
     * TpsGrid afterrender listener.
     * Configure the refresh event to fix scrolling.
     */
    onAfterRender: function(grid) {
        grid.normalGrid.getView().on('refresh', this.fixScroll, grid);
    },

    /**
     * Fix to sync scrolling of TpsGrid locked/normal views.
     * TODO: Fixed in 4.1+?
     */
    fixScroll: function(view) {
	var grid = this,
		normal = grid.normalGrid,
		h = normal.horizontalScroller.rendered ? normal.horizontalScroller.getHeight() : 0;

		if(h > 0) {
		grid.spacerHidden = false;
		grid.getSpacerEl().removeCls(Ext.baseCSSPrefix + 'hidden');
		}
    }
});
