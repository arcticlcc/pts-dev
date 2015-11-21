/**
 * TextareaTriggerField extends TriggerField, replacing the textfield input
 * with a textarea control. The trigger opens a window for editing the text.
 * Useful for editable grids.
 */
Ext.define('PTS.view.controls.TextareaTriggerField', {
    extend: 'Ext.form.field.Trigger',
    alias: 'widget.areatrigger',
    requires: 'Ext.window.Window',

    fieldSubTpl: [
        '<textarea id="{id}" style="height:{height}"',
        '<tpl if="name">name="{name}" </tpl>',
        '<tpl if="rows">rows="{rows}" </tpl>',
        '<tpl if="cols">cols="{cols}" </tpl>',
        '<tpl if="tabIdx">tabIndex="{tabIdx}" </tpl>',
        'class="{fieldCls} {typeCls}" ',
        'autocomplete="off">',
        '</textarea>',
        '<div id="{cmpId}-triggerWrap" class="{triggerWrapCls}" role="presentation">',
        '{triggerEl}',
        '<div class="{clearCls}" role="presentation"></div>',
        '</div>', {
            compiled: true,
            disableFormats: true
        }
    ],
    rows: 2,
    triggerCls: 'pts-trigger-zoom',
    height: 22,
    style: {
        overflow: 'hidden'
    },

    /**
     * @cfg {Boolean} preventScrollbars
     * true to prevent scrollbars from appearing regardless of how much text is in the field. Equivalent to setting overflow: hidden.
     */
    preventScrollbars: true,

    /**
     * Function to perform when the trigger is clicked. By, default
     * a comment editor window is opened. Override to customize.
     */
    onTriggerClick: function(e) {
        var me = this,
            val = me.getRawValue();

        Ext.create('Ext.window.Window', {
            title: 'Comment',
            layout: 'fit',
            width: 400,
            height: 300,
            items: [{
                xtype: 'textarea',
                flex: 1,
                height: '100%',
                value: val
            }],
            buttons: [{
                xtype: 'button',
                text: 'OK',
                handler: function(btn) {
                    var txt = btn.up('window').down('textarea').getRawValue();
                    // process text value and close
                    me.setValue(txt);
                    btn.up('window').close();
                }
            }, {
                xtype: 'button',
                text: 'Cancel',
                handler: function(btn) {
                    btn.up('window').close();
                }
            }],
            resizable: true,
            maximizable: true,
            modal: true,
            animateTarget: me.getEl()
        }).show();
    },

    // private
    onRender: function(ct, position) {
        var me = this;
        Ext.applyIf(me.subTplData, {
            cols: me.cols,
            rows: me.rows
        });

        me.callParent(arguments);
    },

    // private
    afterRender: function() {
        var me = this;

        me.callParent(arguments);

        if (me.preventScrollbars) {
            me.inputEl.setStyle('overflow', 'hidden');
        }
        me.inputEl.setStyle('height', me.height + 'px');
    }
});
