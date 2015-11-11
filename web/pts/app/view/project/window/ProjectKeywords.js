/**
 * GCMD keywords.
 */

Ext.define('PTS.view.project.window.ProjectKeywords', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.projectkeywords',
    requires: [
        'PTS.view.controls.KeywordTree',
        'Ext.ux.grid.FilterBar',
        'Ext.grid.plugin.DragDrop',
        'Ext.grid.column.Template'
    ],

    layout: {
        type: 'border'
    },
    title: 'Keywords',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'gridpanel',
                itemId: 'projectKeywords',
                region: 'center',
                multiSelect: true,
                viewConfig: {
                    stripeRows: false,
                    plugins: {
                        ptype: 'gridviewdragdrop',
                        dropGroup: 'keywords',
                        dragGroup: 'deletekeywords'
                    },
                    getRowClass: function(record, rowIndex, rowParams, store) {
                        return record.phantom ? 'pts-grid-row-phantom' : '';
                    }
                },
                store: 'ProjectKeywords',
                columns: [{
                    text: "Keyword",
                    flex: 1,
                    sortable: true,
                    dataIndex: 'text'
                }],
                title: 'Project Keywords',
                dockedItems: [{
                        xtype: 'toolbar',
                        dock: 'top',
                        items: [{
                                xtype: 'button',
                                iconCls: 'pts-menu-deletebasic',
                                text: 'Remove',
                                action: 'removekeywords'
                            }, {
                                xtype: 'button',
                                iconCls: 'pts-menu-savebasic',
                                text: 'Save',
                                action: 'savekeywords'
                            }, {
                                xtype: 'button',
                                iconCls: 'pts-menu-refresh',
                                text: 'Refresh',
                                action: 'refreshkeywords'
                            }
                            /*,
                                                            {
                                                                xtype: 'image',
                                                                itemId: 'delImage',
                                                                src: 'http://www.sencha.com/img/20110215-feat-html5.png'
                                                            }*/
                        ]
                    }
                    /*,
                                            {
                                                xtype: 'pagingtoolbar',
                                                store: 'ProjectKeywords',
                                                displayInfo: true
                                            }*/
                ]
            }, {
                xtype: 'tabpanel',
                flex: 1,
                title: 'Keywords',
                preventHeader: true,
                region: 'west',
                split: true,
                activeTab: 0,
                tabPosition: 'bottom',
                items: [{
                    xtype: 'keywordtree',
                    itemId: 'keywordTree',
                    title: 'Keyword Tree'
                }, {
                    xtype: 'gridpanel',
                    itemId: 'keywordSearch',
                    title: 'Search',
                    store: 'Keywords',
                    columns: [{
                        xtype: 'gridcolumn',
                        dataIndex: 'text',
                        flex: 1,
                        text: 'Keyword',
                        renderer: function(value, metaData, record, rowIdx, colIdx, store, view) {
                            var fullname = record.get('fullname');

                            if (fullname) {
                                return '<span data-qtip="' + fullname + '">' + value + '</span>';
                            }
                            return value;
                        }
                    }, {
                        xtype: 'gridcolumn',
                        hidden: true,
                        dataIndex: 'fullname',
                        flex: 2,
                        text: 'Full Path'
                    }, {
                        xtype: 'templatecolumn',
                        width: 28,
                        text: '',
                        hideable: false,
                        cls: 'x-action-col-cell',
                        tpl: '<tpl if="definition"><div data-qtip="{[Ext.htmlEncode(values.definition)]}" class="pts-col-info"></div></tpl>'
                    }, {
                        xtype: 'templatecolumn',
                        width: 28,
                        text: '',
                        hideable: false,
                        cls: 'x-action-col-cell',
                        tpl: '<tpl if="text"><div data-qtip="Add: {[Ext.htmlEncode(values.text)]}" class="pts-col-add"></div></tpl>',
                        action: 'addkeyword'
                    }],
                    viewConfig: {
                        copy: true,
                        plugins: {
                            ptype: 'gridviewdragdrop',
                            dragGroup: 'keywords'
                        }
                    },
                    dockedItems: [{
                        xtype: 'filterbar',
                        searchStore: 'Keywords',
                        dock: 'top'
                    }, {
                        xtype: 'pagingtoolbar',
                        displayInfo: true,
                        store: 'Keywords',
                        dock: 'top'
                    }]
                }]
            }]
        });

        me.callParent(arguments);
    }
});
