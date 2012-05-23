/**
 * File: app/view/project/window/ProjectAgreements.js
 * Description: Project Agreements tab panel.
 */

Ext.define('PTS.view.project.window.ProjectAgreements', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.projectagreements',
    requires: [
        'PTS.view.project.window.AgreementsTree'/*,
        'PTS.model.Modification'*/
        //'Ext.ux.grid.HeaderToolTip'
    ],

    layout: {
        type: 'border'
    },
    title: 'Agreements',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            /*dockedItems: [
                {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'button',
                            text: 'New',
                            menu: {
                                xtype: 'menu',
                                items: [
                                    {
                                        xtype: 'menuitem',
                                        text: 'Menu Item'
                                    },
                                    {
                                        xtype: 'menuitem',
                                        text: 'Menu Item'
                                    }
                                ]
                            }
                        },
                        {
                            xtype: 'button',
                            text: 'Edit'
                        },
                        {
                            xtype: 'button',
                            text: 'Delete'
                        }
                    ]
                }
            ],*/
            items: [
                {
                    xtype: 'agreementitemdetail',
                    flex: 2,
                    region: 'center'
                },
                {
                    xtype: 'agreementstree',
                    flex: 1,
                    region: 'west'
                }
            ]
        });

        me.callParent(arguments);
    }
});
