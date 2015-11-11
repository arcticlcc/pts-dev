/**
 * Main TPS Report controller
 */
Ext.define('PTS.controller.tps.Tps', {
    extend: 'Ext.app.Controller',

    init: function() {
        var tab = this.getController('tps.tab.TpsTab');

        // Remember to call the init method manually
        tab.init();

    }
});
