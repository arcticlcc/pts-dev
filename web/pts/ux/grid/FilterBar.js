/**
 * @class Ext.ux.grid.FilterBar
 * @author Josh Bradley (joshua_bradley@fws.gov)
 * Toolbar which adds support for filtering grids
 */
Ext.define("Ext.ux.grid.FilterBar", {
    extend: 'Ext.toolbar.Toolbar',
    alias: 'widget.filterbar',
    requires: [
        'Ext.ux.form.SearchField',
        'Ext.form.field.ComboBox',
        'Ext.data.ArrayStore'
    ],

    /**
     * @cfg {Ext.data.Store} searchStore (required)
     * The store to search.
     */
    searchStore: null,

    /**
     * @cfg {Ext.data.Store} comboStore
     * The store for the search combobox.
     */
    comboStore: Ext.create('Ext.data.ArrayStore', {
        fields:[ 'fieldId', 'fieldName' ],
        data: [ [ 1, 'First Field' ], [ 2, 'Second Field' ] ]
    }),

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'combobox',
                itemId: 'searchCombo',
                fieldLabel: 'Search',
                labelWidth: 50,
                store: me.comboStore,
                queryMode: 'local',
                valueField: 'fieldId',
                displayField: 'fieldName',
                triggerAction: 'all',
                emptyText: 'Select a field',
                listeners: {
                    change: function(cbx, newVal, oldVal) {
                        var disable = newVal === '';
                        cbx.ownerCt.down('searchfield').setDisabled(disable);
                    }
                }
            }, {
                //width: 250,
                flex: 1,
                disabled: true,
                xtype: 'searchfield',
                store: me.searchStore,
                onTrigger1Click : function(){
                    var me = this,
                        store = me.store,
                        //proxy = store.getProxy(),
                        val;

                    if (me.hasSearch) {
                        me.setValue('');
                        //proxy.extraParams[me.paramName] = '';
                        //proxy.extraParams.start = 0;
                        store.clearFilter();
                        //store.load();
                        me.hasSearch = false;
                        me.triggerEl.item(0).setDisplayed('none');
                        me.doComponentLayout();
                    }
                },

                onTrigger2Click : function(){
                    var me = this,
                        store = me.store,
                        field = me.ownerCt.down('#searchCombo').getValue(),
                        //proxy = store.getProxy(),
                        value = me.getValue();

                    if (value.length < 1) {
                        me.onTrigger1Click();
                        return;
                    }
                    //proxy.extraParams[me.paramName] = value;
                    //proxy.extraParams.start = 0;
                    store.filters.clear();
                    store.filter(field, ['ilike', value]);
                    //store.load();
                    me.hasSearch = true;
                    me.triggerEl.item(0).setDisplayed('block');
                    me.doComponentLayout();
                }
            }],
            listeners: {
                added: function(c) {
                    var cols = c.ownerCt.columns,
                        data = [];

                    Ext.each(cols, function(c){
                        if(c.dataIndex) {
                            data.push([c.dataIndex, c.text]);
                        }
                    });

                    c.comboStore.loadData(data);
                }
            }
        });

        me.callParent(arguments);
    }

});
