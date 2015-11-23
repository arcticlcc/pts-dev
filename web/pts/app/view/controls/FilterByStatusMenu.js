/**
 * Combobox that filters parent grid by status.
 */
Ext.define('PTS.view.controls.FilterByStatusMenu', {
    extend: 'Ext.button.Button',
    alias: 'widget.filterstatusmenu',
    requires: ['Ext.menu.Menu', 'Ext.form.field.Checkbox'],

    initComponent: function() {
        var me = this,
            items = [{
                xtype: 'button',
                text: 'Apply',
                handler: me.updateFilter,
                scope: me
            }, '-'],
            menu = Ext.create('Ext.menu.Menu', {
                plain: true,
                items: items
            }),
            store;

        Ext.Ajax.request({
            url: '../status',
            params: {
                sort: '[{"property":"weight","direction":"ASC"}]'
            },
            method: 'GET',
            success: function(response, opts) {
                var obj = Ext.decode(response.responseText);
                Ext.each(obj.data, function(itm) {
                    menu.add({
                        xtype: 'menucheckitem',
                        text: itm.status
                    });
                }, me);

                me.enable();
            },
            failure: function(response, opts) {
                me.disable();
            }
        });

        Ext.applyIf(me, {
            disabled: true,
            text: 'Status',
            tooltip: 'Filter by <b>Status</b>',
            menu: menu
        });
        me.callParent(arguments);
    },

    /**
     * Update and apply filter to the grid
     */
    updateFilter: function() {
        var me = this,
            items = me.ownerCt.query('menu menucheckitem[checked]'),
            store = me.up('grid').getStore(),
            filter = [];

        if (items.length > 0) {
            Ext.each(items, function(itm) {
                filter.push(itm.text);
            });
            //TODO: Fixed in 4.1?
            //http://www.sencha.com/forum/showthread.php?139210-3461-ExtJS4-store-suspendEvents-clearFilter-problem
            store.remoteFilter = false;
            store.clearFilter(true);
            store.remoteFilter = true;
            store.filter([{
                property: 'status',
                value: ['where in', filter]
            }]);

            //me.addCls('pts-bold');
            me.setText('<b>Status</b>');

        } else {
            store.clearFilter();
            //me.removeCls('pts-bold');
            me.setText('Status');
        }
    }
});
