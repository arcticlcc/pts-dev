/**
 * Tree that displays GCMD keywords.
 */
Ext.define('PTS.view.controls.KeywordTree', {
    extend: 'Ext.tree.Panel',
    alias: 'widget.keywordtree',

    //useArrows: true,
    rootVisible: false,
    store: 'KeywordNodes',
    multiSelect: true,
    singleExpand: true,
    cls: 'pts-keyword-tree',
    hideHeaders: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            viewConfig: {
                copy: true,
                plugins: {
                    ptype: 'treeviewdragdrop',
                    dragGroup: 'keywords'
                }
            },
            columns: [
                {
                    xtype: 'treecolumn',
                    text: 'Keyword',
                    dataIndex: 'text',
                    flex:1
                },{
                    xtype: 'templatecolumn',
                    width: 20,
                    text: '',
                    hideable: false,
                    cls: 'x-action-col-cell',
                    tpl: '<tpl if="definition"><div data-qtip="{[Ext.htmlEncode(values.definition)]}" class="pts-col-info"></div></tpl>'
                }
            ]
        });

        me.callParent(arguments);
    }
});
