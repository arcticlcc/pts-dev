/**
 * Description: Metadata panel.
 */

Ext.define('PTS.view.controls.MetadataPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.metadatapanel',
    requires: ['Ext.button.Button', 'Ext.button.Cycle', 'Ext.toolbar.Toolbar'],

    layout: 'card',
    title: 'Metadata',
    defaults: {
        // applied to each contained panel
        border: false,
        autoScroll: true,
        bodyPadding: 10
    },
    /**
     * @cfg {array} formsItems
     * An array of items to add to the form card
     */

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'panel',
                layout: 'fit',
                dockedItems: [{
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [{
                            xtype: 'button',
                            iconCls: 'pts-menu-savebasic',
                            text: 'Save',
                            action: 'save',
                            disabled: true
                        }, {
                            xtype: 'button',
                            iconCls: 'pts-menu-reset',
                            text: 'Reset',
                            action: 'reset'
                        },
                        '->', {
                            xtype: 'button',
                            iconCls: 'pts-menu-json',
                            text: 'Preview JSON',
                            action: 'json'
                        }, {
                            xtype: 'button',
                            iconCls: 'pts-menu-code',
                            text: 'Preview XML',
                            action: 'xml'
                        }, {
                            xtype: 'button',
                            iconCls: 'pts-menu-code',
                            text: 'Preview HTML',
                            action: 'html'
                        }, {
                            xtype: 'cycle',
                            itemId: 'publishBtn',
                            showText: true,
                            menu: {
                                items: [{
                                    iconCls: 'pts-menu-publish',
                                    text: 'Publish',
                                    action: 'DELETE'
                                }, {
                                    iconCls: 'pts-menu-unpublish',
                                    text: 'Unpublish',
                                    action: 'PUT'
                                }]
                            }
                        }
                    ]
                }],
                items: me.formItems
            }, {
                xtype: 'panel',
                layout: 'fit',
                dockedItems: [{
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [{
                        xtype: 'button',
                        iconCls: 'pts-arrow-left',
                        text: 'Back',
                        action: 'goback'
                    }, {
                        xtype: 'button',
                        iconCls: 'pts-menu-add',
                        text: 'Open in Window',
                        action: 'openpreview'
                    }]
                }],
                items: [{
                    xtype: "component",
                    itemId: "metadataPreview",
                    autoEl: {
                        tag: "pre",
                        children: [{
                            tag: 'code'
                        }],
                        style: "border:0;"
                    }
                }]
            }]
        });

        me.callParent(arguments);
    }
});
