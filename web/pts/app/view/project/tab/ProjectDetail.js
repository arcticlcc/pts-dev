/**
 * Project details tab panel
 */

Ext.define('PTS.view.project.tab.ProjectDetail', {
    extend: 'Ext.tab.Panel',
    alias: 'widget.projectdetail',
    requires: [
    ],

    title: 'Project Details',
    activeTab: 0,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            style: {
                backgroundColor: '#FFF',
                backgroundImage: 'none'
            },
            defaults: {
                //autoScroll: true
                layout: 'fit'
            },
            items: [
                {
                    xtype: 'treepanel',
                    itemId: 'projectAgreements',
                    title: 'Agreements',
                    store: 'ProjectAgreementsTree',
                    //cls: 'pts-no-tree-icons',
                    lines: false,
                    useArrows: true,
                    rootVisible: false,
                    viewConfig: {
                        /*getRowClass: function(record, rowIndex, rowParams, store){
                            return record.get("hilite") ? "pts-tree-highlight" : 'pts-tree-header';
                        }*/
                        disableSelection: true
                    },
                    columns: [
                        {
                            xtype: 'treecolumn',
                            dataIndex: 'text',
                            width: 300,
                            text: 'Title'
                        },
                        {
                            xtype: 'gridcolumn',
                            //align: 'center',
                            dataIndex: 'type',
                            text: 'Type',
                            flex: 1
                        }
                    ]
                },
                {
                    xtype: 'panel',
                    title: 'Deliverables',
                    disabled: true
                },
                {
                    xtype: 'panel',
                    title: 'Contacts',
                    disabled: true
                }/*,
                {
                    xtype: 'panel',
                    title: 'Files'
                }*/
            ]
        });

        me.callParent(arguments);
    }
});
