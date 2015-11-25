/**
 * Controller for MainToolbar
 */
Ext.define('PTS.controller.MainToolbar', {
    extend: 'Ext.app.Controller',
    views: [
        'MainToolbar',
        'PTS.view.config.Window'
    ],
    /*refs: [{
        ref: 'viewport',
        selector: 'viewport'
    }],*/
    init: function() {
        this.control({
            'maintoolbar #userBtn': {
                beforerender: this.onBeforeShowUserBtn
            },
            'maintoolbar #switchPTS menu': {
                click: this.onClickSwitchPTS
            },
            'maintoolbar #configBtn': {
                click: this.showSettings
            }
        });
    },

    /**
     * Set user name. Add switch PTS options.
     */
    onBeforeShowUserBtn: function(btn) {
        var txt = PTS.user.getUserName(),
            menu = btn.menu.down('#switchPTS').menu;

        btn.setText(txt);

        menu.add(PTS.UserId.paths);
        menu.down('menuitem[url=' + window.location.pathname + ']').disable();
    },

    /**
     * Handle clicks on switchPTS button.
     */
    onClickSwitchPTS: function(menu, item) {
        this.switchPTS(item.url);
    },

    /**
     * Switch PTS by setting window location.
     */
    switchPTS: function(location) {
        window.location.href = location;
    },

    /**
     * Open settings window.
     */
    showSettings: function(btn) {
        if (PTS.userConfigWindow === undefined) {
            PTS.userConfigWindow = Ext.create('PTS.view.config.Window');
        }

        PTS.userConfigWindow.show();
    }
});
