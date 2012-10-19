/**
 * Main Report controller
 */
Ext.define('PTS.controller.report.Report', {
    extend: 'Ext.app.Controller',

    init: function() {
        var tab = this.getController('report.tab.ReportTab');

        // Remember to call the init method manually
        tab.init();

    }
});
