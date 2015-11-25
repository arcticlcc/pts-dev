/**
 * Description: Configuration settings window containing form panel.
 */
Ext.define('PTS.view.config.Window', {
    extend: 'Ext.window.Window',
    alias: 'widget.configwindow',
    requires: [
        'Ext.form.Panel'
    ],

    //height: Ext.Element.getViewportHeight() - 40,
    minHeight: 250,
    //width: 900,
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
    title: 'Edit Settings',
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
            action: 'close'
        });
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'form',
                items: [{
                    xtype: 'combobox',
                    editable: false, 
                    store: ['Red', 'Yellow', 'Green', 'Brown', 'Blue', 'Pink', 'Black']                     
                }]
            }],
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    xtype: 'tbfill'
                }, {
                    xtype: 'button',
                    text: 'Save',
                    action: 'save'
                }, {
                    xtype: 'button',
                    text: 'Close',
                    action: 'close'
                }]
            }]
        });

        me.callParent(arguments);
    }
});
