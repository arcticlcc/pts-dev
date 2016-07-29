/**
 * Basic html text link
 */

Ext.define('PTS.view.controls.SimpleLink', {
    extend: 'Ext.Component',
    alias: 'widget.simplelink',

    baseCls: Ext.baseCSSPrefix + 'simplelink',
    maskOnDisable: true,
    getElConfig: function () {
        var me = this;
        return {
            tag: 'a',
            id: me.id,
            href: '#',
            html: me.text ? Ext.util.Format.htmlEncode(me.text) : (
                me.html ||
                '')
        };
    },

    initComponent: function () {
        var me = this;

        me.on('afterRender', function () {
            me.mon(me.getEl(), 'click', me.handler, me);
        });

        me.callParent(arguments);
    },

    handler: Ext.emptyFn
});
