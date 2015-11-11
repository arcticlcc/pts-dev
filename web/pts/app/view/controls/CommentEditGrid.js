/**
 * Abstract grid for editing comments.
 */
Ext.define('PTS.view.controls.CommentEditGrid', {
    extend: 'PTS.view.controls.RowEditGrid',
    alias: 'widget.commenteditgrid',
    requires: [
        'Ext.grid.plugin.RowEditing',
        'PTS.store.GroupUsers',
        'PTS.view.controls.TextareaTriggerField'
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
    columns: [{
        xtype: 'gridcolumn',
        dataIndex: 'comment',
        text: 'Comment',
        flex: 1,
        editor: {
            xtype: 'areatrigger',
            text: 'Comment'
        }
    }, {
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
    }, {
        xtype: 'datecolumn',
        dataIndex: 'datemodified',
        text: 'Date'
    }],

    initComponent: function() {
        var me = this;

        /*Ext.applyIf(me, {
        });*/

        me.callParent(arguments);
        me.getStore().on('add', function(store, records) {
            Ext.each(records, function() {
                var rec = this;

                if (null === rec.get('contactid')) {
                    rec.set('contactid', PTS.user.get('contactid'));
                }
            });
        });
        me.on('edit', function(editor, e) {
            var rec = editor.record;
            if (rec.dirty) {
                rec.beginEdit();
                rec.set('datemodified', new Date());
                rec.endEdit();
            }
        });
    }

});
