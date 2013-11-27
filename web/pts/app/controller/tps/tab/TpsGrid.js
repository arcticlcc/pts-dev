/**
 * Controller for TPS Grid
 */
Ext.define('PTS.controller.tps.tab.TpsGrid', {
    extend: 'Ext.app.Controller',

    stores: [    
        'TpsRecords',    
        'ModDocTypes',
        'ModDocStatuses',
        'ModDocStatusTypes'        
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
    },{
        ref: 'detailGrid',
        selector: 'tpstab tpsdetailgrid#tpsDetail'
    }],

    init: function() {

        this.control({
            'tpstab tpsgrid#tpsGrid': {
                afterrender: this.onAfterRender,
                beforeselect: this.onBeforeSelect
            },
            'tpstab tpsdetailgrid#tpsDetail': {
                edit: this.onDetailRowEdit,
                removerow: this.onDetailRowRemove
            }
        });

    },
    
    /**
     * TpsGrid afterrender listener.
     * Configure the refresh event to fix scrolling.
     */
    onAfterRender: function(grid) {
        grid.normalGrid.getView().on('refresh', this.fixScroll, grid);
        grid.getSelectionModel().on('select', this.onSelect, this);
        grid.getSelectionModel().on('deselect', this.onDeselect, this);
        
    },    

    /**
     * TpsGrid select listener.
     * Load the  detailGrid based on the selected cell.
     * Highlight the locked cells of the row selected.
     * Update the title of the detailGrid.
     */
    onSelect: function(sm, record, row, col) {
        var col = sm.primaryView.ownerCt.columns[col];
            doctypeid = col.dataIndex.split('_')[1],
            modid = record.get('modificationid'),
            store = this.getModDocStatusesStore();        

        sm.view.up('tpsgrid').lockedGrid.getView().addRowCls(row, 'pts-tps-highlight');
        
        //override store proxy based on contactid
        store.setProxy({
            type: 'rest',
            url : '../moddocstatus',
            appendId: true,
            //batchActions: true,
            api: {
                read: '../modification/' + modid + '/moddoctype/' + doctypeid + '/moddocstatus',
                //update: '../modification/' + modid + '/moddoctype/' + doctypeid + '/moddocstatus'
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
        
        store.load({
            callback: function(records, operation, success) {
                var title = success ? 'Details for <i>' + col.text + '</i> (' + record.get('projectcode') + ')' : 'Load Failed!';
                
                this.getDetailGrid().setTitle(title);
            },
            scope: this
        });      
    },

    /**
     * TpsGrid deselect listener.
     * Remove highlight.
     */
    onDeselect: function(sm, record, row, col) {
        sm.view.up('tpsgrid').lockedGrid.getView().removeRowCls(row, 'pts-tps-highlight');        
    },

    /**
     * Update the record in the roweditgrid store with the deliverableid.
     */
    onDetailRowEdit: function(editor, e) {
        var tgrid = this.getTpsGrid(),
            cell = tgrid.getSelectionModel().getCurrentPosition(),        
            rec = Ext.getStore('TpsRecords').getAt(cell.row),
            col = tgrid.normalGrid.columns[cell.column],
            doctypeid = col.dataIndex.split('_')[1],
            modid = rec.get('modificationid');

        editor.record.set('modificationid', modid);
        editor.record.set('moddoctypeid', doctypeid);

        editor.store.sync({
            success: function(batch) {                    
                if(batch.isComplete && !batch.hasException) {
                    this.updateCell(rec, col);
                }    
            },
            scope: this
        });

    },

    /**
     * Update the cell.
     */
    onDetailRowRemove: function(record, store) {
        var rec = this.getTpsRecordsStore().findRecord('modificationid',record.get('modificationid') , 0, false, true, true),
            col = this.getTpsGrid().normalGrid.headerCt.child('gridcolumn[dataIndex=doctype_' + record.get('moddoctypeid') + ']');
            
        this.updateCell(rec, col);
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
    },

    /**
     * Update the cell in the TpsGrid.
     */
    updateCell: function(rec, col) {
        var me = this,
            typestore = me.getModDocStatusTypesStore(),
            store = me.getModDocStatusesStore(),
            typeid,
            html,                        
            sorter = [{
                property: 'effectivedate',
                direction: 'DESC'
            },{
                property: 'weight',
                direction: 'DESC'
            }];
        if(store.count() > 0) {                    
            store.sort(sorter);
            typeid = store.first().get('moddocstatustypeid');
            html = PTS.util.Format.docStatus(typestore.findRecord('moddocstatustypeid', typeid, 0, false, true, true).get('code')); 
        }else {
            html = PTS.util.Format.docStatus('Not Started');
        }       
        me.getTpsGrid().getView().getCell(rec, col).down('div').dom.innerHTML = html;
    }
});
