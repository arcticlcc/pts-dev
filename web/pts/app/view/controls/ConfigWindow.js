/**
 * Window that applies user settings.
 */
Ext.define('PTS.view.controls.ConfigWindow', {
    extend: 'Ext.window.Window',
    alias: 'widget.configwindow',

    initComponent: function() {
        var me = this,
            configWidth = PTS.userConfig.get('windowWidth'),
            vpWidth = Ext.Element.getViewportWidth() -20;

        width = me.width ? me.width : configWidth > 0 ? configWidth : 900;

        Ext.applyIf(me, {
            width: width < vpWidth ? width : vpWidth,
            maximized: (configWidth === 0)
        });

        me.callParent(arguments);
    }
});
