/**
 * File: app/view/project/window/Window.js
 * Description: Project window containing tab panel.
 */
Ext.define('PTS.view.project.window.Window', {
    extend: 'Ext.window.Window',
    alias: 'widget.projectwindow',
    requires: [
        'PTS.view.project.form.ProjectForm',
        'PTS.view.project.window.ProjectContacts',
        'PTS.view.project.window.ProjectAgreements',
        'PTS.view.controls.CommentEditGrid',
        'PTS.view.project.window.ProjectKeywords'
    ],

    height: Ext.Element.getViewportHeight() - 40,
    minWidth: 750,
    width: 900,
    layout: {
        type: 'fit'
    },

    /**
     * @cfg {Boolean} closable
     * This needs to be set to false since we're using a
     * custom close tool.
     */
    closable: false,
    maximizable: true,
    title: 'Edit Project',
    constrain: true,
    modal: true,
    y: 10,

    /**
     * Adds the custom close tool.
     */
    addTools: function() {
        var me = this;

        // Call Panel's initTools
        me.callParent();

        me.addTool({
            xtype: 'tool',
            type: 'close',
            action: 'closewindow'
        });
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'tabpanel',
                    itemId: 'projecttabpanel',
                    items: [
                        {
                            xtype: 'projectform'
                        },
                        {
                            xtype: 'projectcontacts'
                        },
                        {
                            xtype: 'projectagreements'
                        },
                        {
                            title: 'Comments',
                            xtype: 'commenteditgrid',
                            store: 'ProjectComments'
                        },
                        {
                            xtype: 'projectkeywords'
                        }
                    ]
                }
            ],
            dockedItems: [
                {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: [
                        {
                            xtype: 'tbfill'
                        },
                        /*{//TODO: save all button
                            xtype: 'button',
                            text: 'Save All',
                            action: 'saveall'
                        },*/
                        {
                            xtype: 'button',
                            text: 'Close',
                            action: 'closewindow'
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
