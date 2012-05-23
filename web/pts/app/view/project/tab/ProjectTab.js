/**
 * File: app/view/project/ProjectTab.js
 * Description: Dashboard calendar displaying deliverables and tasks.
 */

Ext.define('PTS.view.project.tab.ProjectTab', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.projecttab',
    requires: [
        /*'ArcticPTS.view.ProjectDetailsCSM'*/
        'PTS.view.project.tab.ProjectList',
        'PTS.view.project.tab.ProjectDetail'
    ],

    layout: {
        type: 'border'
    },
    title: 'Projects',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            dockedItems: [
                {
                    xtype: 'toolbar',
                    //id: 'alccProjectToolbar',
                    //region: 'center',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'button',
                            iconCls: 'pts-menu-add',
                            text: 'Add Project',
                            itemId: 'newprojectbtn',
                            action: 'addproject'
                        },
                        {
                            xtype: 'button',
                            iconCls: 'pts-menu-edit',
                            text: 'Edit Project',
                            itemId: 'editprojectbtn',
                            action: 'editproject',
                            disabled: true
                        }
                    ]
                }
            ],
            items: [
                {
                    xtype: 'projectlist',
                    region: 'center',
                    //id: 'alcc-project-grid',
                    itemId: 'pts-project-grid'
                },
                {
                    xtype: 'panel',
                    width: 150,
                    layout: {
                        type: 'border'
                    },
                    bodyStyle: {
                        border: 'none',
                        backgroundColor: '#FFF',
                        backgroundImage: 'none'
                    },
                    collapsible: true,
                    animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                    preventHeader: true,
                    title: 'Project Details',
                    flex: 1,
                    region: 'east',
                    split: true,
                    defaults: {
                        preventHeader: true
                    },
                    items: [
                        {
                            xtype: 'projectdetail',
                            //xtype: 'panel',
                            //title: 'Project Details',
                            region: 'center'
                        },
                        {
                            //xtype: 'projectdetailscsm',
                            xtype: 'panel',
                            flex: 1,
                            region: 'south',
                            split: true
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
