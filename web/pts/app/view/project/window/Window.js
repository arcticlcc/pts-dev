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
        'PTS.view.project.window.ProjectAgreements'
    ],

    height: Ext.Element.getViewportHeight() - 40,
    minWidth: 750,
    width: 900,
    layout: {
        type: 'fit'
    },
    closable: false,
    title: 'Edit Project',
    constrain: true,
    modal: true,
    y: 10,

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
            ],
            tools: [
                /*{
                    xtype: 'tool',
                    type: 'save'
                },*/
                {
                    xtype: 'tool',
                    type: 'close',
                    action: 'closewindow'
                }
            ]
        });

        me.callParent(arguments);
    }
});
