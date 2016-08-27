/**
 * Description: Create issue window containing form panel.
 */
Ext.define('PTS.view.issue.Window', {
    extend: 'Ext.window.Window',
    alias: 'widget.issuewindow',
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
    //closable: false,
    //closeAction: 'hide',
    maximizable: true,
    title: 'Create New Issue',
    constrain: true,
    modal: false,
    y: 20,
    width: 600,
    minWidth: 600,

    /**
     * Adds the custom close tool.
     */
    /*addTools: function() {
        var me = this;

        // Call Panel's initTools
        me.callParent();

        me.addTool({
            xtype: 'tool',
            type: 'close',
            action: 'close'
        });
    },*/

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'form',
                trackResetOnLoad: true,
                bodyPadding: 15,
                url: PTS.baseURL + '/github/issue',
                method:'POST',
                layout: 'anchor',
                defaults: {
                    anchor: '100%'
                },
                items: [{
                    xtype: 'textfield',
                    fieldLabel: 'Title',
                    name: 'title',
                    allowBlank: false,
                    minLength: 3
                }, {
                    xtype: 'htmleditor',
                    height: 400,
                    fieldLabel: 'Description',
                    name: 'body',
                    qtip: 'Enter a description of the issue.',
                    allowBlank: false,
                    enableColors: false,
                    enableFont: false,
                    enableFontSize: false,
                    enableAlignments: false
                }],
                buttons: [{
                  xtype: 'button',
                  iconCls: 'pts-menu-savebasic',
                  text: 'Save',
                  action: 'save',
                  formBind: true,
                  disabled: true
                }, {
                  xtype: 'button',
                  text: 'Close',
                  action: 'closeIssue',
                  handler: function(btn) {
                      btn.up('window').close();
                  }
            }]
            // dockedItems: [{
            //   xtype: 'toolbar',
            //   dock: 'bottom',

              }]

            // }]

        });

        me.callParent(arguments);
    }
});
