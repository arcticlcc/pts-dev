/**
 * @class Ext.ux.StoreMenu
 * @extends Ext.menu.Menu
 * <p>Renders a menu from a store.</p>
 */
Ext.define('Ext.ux.StoreMenu', {
    extend: 'Ext.menu.Menu',
    alias: 'widget.storemenu',

    plain: true,

    /**
     * @cfg {Ext.data.Store} store (required)
     * The {@link Ext.data.Store Store} the grid should use as its data source.
     */

    /**
     * @cfg {string} loadingCls
     * The iconCls the loading item should use.
     */
    loadingCls: undefined,

    initComponent: function() {
        var me = this;

        // Look up the configured Store. If none configured, use the fieldless, empty Store defined in Ext.data.Store.
        me.store = Ext.data.StoreManager.lookup(me.store || 'ext-empty-store');

        me.callParent(arguments);

        me.on('render', function(menu) {
            if(!menu.store.data.getCount() > 0) {
                //menu.setLoading(true);
                menu.add({
                    text:'Loading...',
                    iconCls: me.loadingCls,
                    hideOnClick: false,
                    disabled: true
                });
                menu.store.load();
            }else {
                menu.store.each(function(rec){
                    me.add({
                        text: rec.get('text'),
                        itemId: rec.getId()
                    });
                }, me);
            }
        });

        me.store.on('load', function(store, records, success) {
            me.removeAll();
            store.each(function(rec){
                me.add({
                    text: rec.get('text'),
                    itemId: rec.getId()
                });
            }, me);
        });
    }
});
