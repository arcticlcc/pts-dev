/**
 * Panel with tree panel listing available reports and
 * tab panel to display reports.
 */

Ext.define('PTS.view.report.tab.ReportTab', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.reporttab',
    requires: [
        'PTS.view.report.ReportGrid'
    ],

    layout: {
        type: 'border'
    },
    title: 'Reports',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'tabpanel',
                itemId: 'reportPanel',
                activeTab: 0,
                region: 'center',
                items: [{
                        xtype: 'panel',
                        itemId: 'helpTab',
                        title: 'Help',
                        closable: false,
                        closeAction: 'hide',
                        hidden: true,
                        bodyPadding: 10,
                        html: 'Choose a report from the tree on the left. ' +
                            'The report will open in a new tab. Tabs may be closed by clicking the button ' +
                            '<img height="11px" width="11px" src="extjs/resources/themes/images/default/tab/tab-default-close.gif"/> ' +
                            'next to the title. <br /> Some reports have columns that are hidden by default. Hover your pointer over the ' +
                            'column title and click the down arrow ' +
                            '<img height="11px" width="11px" src="extjs/resources/themes/images/default/button/arrow.gif"/> ' +
                            'next to the title to display or hide columns.'
                    }

                ]
            }, {
                xtype: 'treepanel',
                itemId: 'reportTree',
                width: 225,
                title: 'Reports',
                region: 'west',
                store: 'ReportTree',
                rootVisible: false,
                split: true
            }]
        });

        me.callParent(arguments);
    }
});
