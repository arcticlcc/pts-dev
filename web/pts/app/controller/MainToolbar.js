/**
 * Controller for MainToolbar
 */
Ext.define('PTS.controller.MainToolbar', {
    extend: 'Ext.app.Controller',
    views: [
        'MainToolbar'
    ],
    /*refs: [{
        ref: 'viewport',
        selector: 'viewport'
    }],*/
    init: function() {
        this.control({
            'maintoolbar #userBtn': {
                beforerender: this.onBeforeShowUserBtn
            }
        });
    },

    /**
     * Set user name.
     */
    onBeforeShowUserBtn: function(btn) {
        var txt = PTS.user.getUserName();
        btn.setText(txt);
    }
});
