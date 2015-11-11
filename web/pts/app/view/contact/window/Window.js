/**
 * File: app/view/contact/window/Window.js
 * Description: Edit contact window.
 */

Ext.define('PTS.view.contact.window.Window', {
    extend: 'Ext.window.Window',
    alias: 'widget.contactwindow',
    requires: [
        'PTS.view.contact.window.ContactForm'
    ],

    height: Ext.Element.getViewportHeight() - 40,
    minWidth: 750,
    width: 900,
    layout: {
        type: 'border'
    },
    closable: false,
    title: 'Edit Contact',
    constrain: true,
    modal: true,
    y: 10,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                    xtype: 'contactform',
                    region: 'center'
                }
                /*,
                                {
                                    xtype: 'contactcontactstab'
                                },
                                {
                                    xtype: 'contactagreementstab'
                                }*/
            ],
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
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
            }],
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
