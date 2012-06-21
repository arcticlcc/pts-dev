/**
 * Abstract grid for editing comments.
 */
Ext.define('PTS.view.controls.CommentEditGrid', {
    extend: 'PTS.view.controls.RowEditGrid',
    alias: 'widget.commenteditgrid',
    requires: [
        'Ext.grid.plugin.RowEditing',
        'PTS.store.GroupUsers'
    ],

    /**
     * @cfg {Boolean} syncOnRemoveRow
     * @inheritdoc PTS.view.controls.RowEditGrid#syncOnRemoveRow
     */

    /**
     * @cfg {Ext.data.Store} store (required)
     * @inheritdoc Ext.panel.Table#store
     */

    /**
     * @cfg {Ext.grid.column.Column[]} columns
     * @inheritdoc Ext.panel.Table#columns
     */
    columns: [
        {
            xtype: 'gridcolumn',
            dataIndex: 'comment',
            flex: 1,
            editor: {
                xtype: 'textareafield',
                height: 22,
                style: {overflow: 'hidden'},
                allowBlank: false,
                blankText: 'A comment is required.',
                listeners: {
                    focus: {
                        fn: function(f){
                            var val = f.getRawValue();
                            //TODO: extract this functionality into a plugin
                            if(val.length > 50){
                                Ext.MessageBox.show({
                                    title: 'Comment',
                                    //msg: 'Comment:',
                                    width:300,
                                    buttons: Ext.MessageBox.OKCANCEL,
                                    multiline: true,
                                    value: val,
                                    fn: function(btn, txt) {
                                        if (btn === 'ok'){
                                        // process text value and close
                                            f.setValue(txt);
                                        }
                                    },
                                   animateTarget: f.getEl()
                               });
                            }
                        }
                    }
                }
            },
            text: 'Comment'
        },
        {
            xtype: 'gridcolumn',
            dataIndex: 'contactid',
            width: 150,
            renderer: function(value) {
                var store = Ext.getStore('GroupUsers'),
                    idx = store.find('contactid', value, 0, false, true, true),
                    rec = store.getAt(idx);
                if (rec) {
                    return rec.get('fullname');
                }
                return value;
            },
            text: 'User'
        },
        {
            xtype: 'datecolumn',
            dataIndex: 'datemodified',
            text: 'Date'
        }
    ],

    initComponent: function() {
        var me = this;

        /*Ext.applyIf(me, {
        });*/

        me.callParent(arguments);
        /*me.on('beforeedit', function(e) {
            var rec = e.record;

            if(null === rec.get('contactid')) {
                rec.set('contactid', PTS.user.get('contactid'));
            }

            e.cancel = false;
            return true;
        });*/
    }

});
