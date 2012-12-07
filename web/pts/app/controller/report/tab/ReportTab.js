/**
 * Controller for ReportTab
 */
Ext.define('PTS.controller.report.tab.ReportTab', {
    extend: 'Ext.app.Controller',

    stores: [
        'ReportTree'
    ],
    models: [
        'ReportTree'
    ],
    views: [
        'report.tab.ReportTab',
        'report.ReportGrid'
    ],

    refs: [{
        ref: 'reportTree',
        selector: 'reporttab #reportTree'
    },{
        ref: 'reportPanel',
        selector: 'reporttab #reportPanel'
    },{
        ref: 'helpTab',
        selector: 'reporttab #helpTab'
    }],

    init: function() {

        this.control({
            'reporttab #reportTree': {
                itemclick: this.onClickItem
            },
            'reporttab #reportPanel': {
                add: this.onAddTab
            }
        });

    },

    /**
     * Click listener for report tree items.
     */
    onClickItem: function(rm, rec, index,opts) {
        var grid, storecfg,
            itemId = rec.internalId + '-reportgrid',
            rp = this.getReportPanel(),
            tab = rp.down('#'+itemId);

        storecfg = {
            //fields: rec.data.fields,
            proxy: {
                type: 'ajax',
                url : rec.data.url,
                reader: {
                    type: 'json',
                    root: 'data'
                }
            },
            autoLoad: true,
            remoteSort: true
        };

        if(rec.data.model) {
            storecfg.model = rec.data.model;
        }else {
            storecfg.fields = rec.data.fields;
        }

        if(rec.isLeaf()) {
            if(tab) {
                rp.setActiveTab(tab);
            }else {
                tab = {
                    xtype: rec.data.xtype ? rec.data.xtype : 'reportgrid',
                    filterBar: !!rec.data.filterBar,
                    itemId: itemId,
                    closable: true,
                    title: rec.data.text,
                    store: Ext.create('Ext.data.Store', storecfg)
                };
                if(rec.data.cols) {
                    tab.columns = rec.data.cols;
                }
                rp.add(tab);
            }
        }
    },

    /**
     * Add listener for report panel.
     * We use the added event here to make sure the
     * tab item has been rendered before activating.
     */
    onAddTab: function(panel, tab) {
        panel.setActiveTab(tab);
    }
});
