/**
 * File: app/view/project/window/AgreementsTree.js
 * Description: Project Agreements tree panel.
 */

Ext.define('PTS.view.project.window.AgreementsTree', {
    extend: 'Ext.tree.Panel',
    alias: 'widget.agreementstree',
    requires: [
       'Ext.tree.plugin.TreeViewDragDrop'
    ],

    border: '0 0 0 1',
    title: 'Agreements',
    store: 'AgreementsTree',
    rootVisible: false,
    useArrows: true,
    viewConfig: {
        copy: true,
        plugins: {
            ptype: 'treeviewdragdrop',
            pluginId: 'agreementsddplugin'
        },
        //Get agreement id node belongs to
        getAgreementId: function (record) {
            var i,
            ln = record.getDepth();

            for (i = 0; i < ln; i++) {
                if (record.parentNode.get('typeid') === 20) {
                    return record.getId();
                }else {
                    record = record.parentNode;
                }
            }
        },
        //Get agreement id node belongs to
        getDataId: function (record,type) {
            var i,
            ln = record.getDepth();

            for (i = 0; i < ln; i++) {
                if (record.parentNode.get('typeid') === type) {
                    return record.get('dataid');
                }else {
                    record = record.parentNode;
                }
            }
        }
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            columns: [
                {
                    xtype: 'treecolumn',
                    dataIndex: 'text',
                    flex: 3,
                    text: 'Title'
                },
                {
                    xtype: 'gridcolumn',
                    width: 75,
                    align: 'center',
                    dataIndex: 'type',
                    text: 'Type'
                }
            ],
            tools: [
                {
                    xtype: 'tool',
                    tooltip: 'Refresh',
                    type: 'refresh',
                    hidden: false
                },{
                    xtype: 'tool',
                    tooltip: 'Expand All',
                    type: 'expand'
                },
                {
                    xtype: 'tool',
                    tooltip: 'Collapse All',
                    type: 'collapse',
                    hidden: true
                }
            ]
        });

        me.callParent(arguments);
    }
});
