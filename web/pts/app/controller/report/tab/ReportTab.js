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
    }, {
        ref: 'reportPanel',
        selector: 'reporttab #reportPanel'
    }, {
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
    onClickItem: function(rm, rec, index, opts) {
        var grid, storecfg, plugins,
            data = rec.data,
            itemId = rec.internalId + '-reportgrid',
            rp = this.getReportPanel(),
            tab = rp.down('#' + itemId);

        if (rec.isLeaf()) {
            if (tab) {
                rp.setActiveTab(tab);
            } else {
                storecfg = {
                    //fields: data.fields,
                    proxy: {
                        type: 'ajax',
                        url: data.url,
                        reader: {
                            type: 'json',
                            root: 'data'
                        }
                    },
                    autoLoad: true,
                    remoteSort: true
                };

                if (data.limit) {
                    storecfg.pageSize = data.limit;
                }

                if (data.model) {
                    storecfg.model = data.model;
                } else {
                    storecfg.fields = data.fields;
                }
                tab = {
                    xtype: data.xtype ? data.xtype : 'reportgrid',
                    filterBar: !!data.filterBar,
                    itemId: itemId,
                    closable: true,
                    title: data.text,
                    store: Ext.create('Ext.data.Store', storecfg),
                    tabConfig: {
                        tooltip: data.qtip
                    }
                };
                if (data.cols) {
                    Ext.each(data.cols, function(c) {
                        if (c.renderer) {
                            c.renderer = Ext.util.Format[c.renderer];
                        }
                    });
                    tab.columns = data.cols;
                }
                if (data.summary) {
                    tab.features = [{
                        ftype: 'summary'
                    }];
                }
                if (data.pbarPlugins) {
                    tab.pbarPlugins = [];

                    Ext.each(data.pbarPlugins, function(p) {
                        tab.pbarPlugins.push(
                            Ext.create(p.type, p.cfg)
                        );
                    });
                }
                if (data.filterBar) {
                    if (tab.dockedItems === undefined) {
                        tab.dockedItems = [];
                    }
                    tab.dockedItems.push({
                        xtype: 'filterbar',
                        searchStore: tab.store,
                        dock: 'bottom'
                    });

                    tab.store.remoteFilter = true;
                }

                tab.store.remoteFilter = data.remoteFilter;

                rp.add(tab);

                if (data.pbarItems) {
                    var pbar = rp.down('#' + tab.itemId + ' pagingtoolbar');

                    Ext.each(data.pbarItems, function(p) {
                        pbar.insert(pbar.items.length - 2, Ext.create(p.type, p.cfg));
                    });
                }
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
