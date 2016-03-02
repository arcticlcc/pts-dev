/**
 * Description: Configuration settings window containing form panel.
 */
Ext.define('PTS.view.config.Window', {
    extend: 'Ext.window.Window',
    alias: 'widget.configwindow',
    requires: [
        'Ext.form.Panel'
    ],

    layout: {
        type: 'fit'
    },

    /**
     * @cfg {Boolean} closable
     * This needs to be set to false since we're using a
     * custom close tool.
     */
    closable: false,
    closeAction: 'hide',
    maximizable: true,
    title: 'Edit Settings',
    constrain: true,
    modal: false,
    y: 20,

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
                trackResetOnLoad: true,
                bodyPadding: 15,
                items: [{
                    xtype: 'combobox',
                    fieldLabel: 'Window Width',
                    name: 'windowWidth',
                    qtip: 'Sets the default width for editor windows.',
                    editable: false,
                    store: [
                        [900, 'normal'],
                        [1200, 'wide'],
                        [0, 'maximize']
                    ]
                }, {
                    xtype: 'combobox',
                    fieldLabel: 'Page Size',
                    name: 'pageSize',
                    qtip: 'Sets the default page size for grids. Select an option or enter a custom value.',
                    editable: true,
                    store: [
                        [25, 25],
                        [30, 30],
                        [40, 40],
                        [50, 50]
                    ]
                }]
            }],
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    xtype: 'tbfill'
                }, {
                    xtype: 'button',
                    iconCls: 'pts-menu-savebasic',
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

        me.down('form').loadRecord(PTS.userConfig);
    }
});
