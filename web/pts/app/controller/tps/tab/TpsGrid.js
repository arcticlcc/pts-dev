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
            },
            'tpstab tpsgrid#tpsGrid button[action=filterrecords]': {
                change: this.filterRecords
            }
        });

    },
    
    /**
     * TpsGrid afterrender listener.
     * Configure the refresh event to fix scrolling.
     */
    onAfterRender: function(grid) {
        var normal = grid.normalGrid,
            sm = grid.getSelectionModel(),
            tip = new Ext.ux.grid.HeaderToolTip;
        
        tip.createTip.call(normal);
        tip.destroy();
        
        normal.getView().on('refresh', this.fixScroll, grid);
        grid.lockedGrid.getView().on('itemdblclick', this.onTpsGridDblClick, this);
        sm.on('select', this.onSelect, this);
        sm.on('deselect', this.onDeselect, this);                
        
    },    

    /**
     * TpsGrid select listener.
     * Load the  detailGrid based on the selected cell.
     * Highlight the locked cells of the row selected.
     * Update the title of the detailGrid.
     */
    onSelect: function(sm, record, row, col) {
        var col = sm.primaryView.ownerCt.columns[col],
            val = record.data[col.dataIndex],
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

        if(val === null) {
            this.getDetailGrid().disable();
            var title = 'Details for <i>' + col.text + '</i> (' + record.get('projectcode') + ')';
            
            this.getDetailGrid().setTitle(title);            
        }else{
            this.getDetailGrid().enable();
            
            store.load({
                callback: function(records, operation, success) {
                    var title = success ? 'Details for <i>' + col.text + '</i> (' + record.get('projectcode') + ')' : 'Load Failed!';
                    
                    this.getDetailGrid().setTitle(title);
                },
                scope: this
            });            
        }        
      
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
    },

    /**
     * Filter the records
     * @param {Ext.button.Cycle} btn The cycle button
     * @param {Ext.menu.CheckItem} item The menu item that was selected
     */
    filterRecords: function(btn, itm) {
        var store = this.getTpsRecordsStore();
        //TODO: Fixed in 4.1?
        //http://www.sencha.com/forum/showthread.php?139210-3461-ExtJS4-store-suspendEvents-clearFilter-problem
        store.remoteFilter = false;
        store.clearFilter(true);
        store.remoteFilter = true;

        switch(itm.filter) {
            case 'active':
                store.filter({
                    property: 'weight',
                    value: ['<',40]
                });
                break;
            case 'funded':
                store.filter({
                    property: 'weight',
                    value: ['>=',40]
                });
                break;
            default:
                store.loadPage(1);
        }
    },

    /**
     * TPS grid double click handler
     * @param {Ext.view.View} view
     * @param {Ext.data.Model} record The record that belongs to the item
     * @param {HTMLElement} item The item's element
     */    
    onTpsGridDblClick: function(view, rec, el) {
        console.info(rec);
        this.openProject(rec);       
    },
    
    /**
     * Open the project window and show the agreement
     * @param {Ext.data.Model} rec The record for the clicked row
     * 
     * TODO: Create method in main project controller to handle this.
     * Similar methods currently implemented in multiple controllers.
     */
    openProject: function(rec) {
        var id = rec.get('modificationid'),
            callBack = function() {
            var win = this,
                store = win.down('agreementstree').getStore(),
                tab = win.down('projectagreements'),
                setPath = function(store) {
                    var path = store.getNodeById("af-" + id).getPath();
                    this.down('agreementstree').selectPath(path);
                    this.getEl().unmask();
                };

            //Ext.getBody().unmask();
            win.getEl().mask('Loading...');
            win.down('tabpanel').setActiveTab(tab);

            if(store.getRootNode().hasChildNodes()) {
                setPath(store);
            }else {
                store.on('load', setPath, win, {
                    single: true
                });
            }
        };
        //set the getProjectCode method, if it doesn't exist
        //we assume that the record contains the projectcode
        if(rec.getProjectCode === undefined) {
            rec.getProjectCode = function() {
                return rec.get('projectcode');
            };
        }

        this.getController('project.Project').openProject(rec,callBack);
    }        
});
