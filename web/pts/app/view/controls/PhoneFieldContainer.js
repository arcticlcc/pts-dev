/**
 * Fieldcontainer configured for phone numbers
 */
Ext.define('PTS.view.controls.PhoneFieldContainer', {
    extend: 'PTS.view.controls.MyFieldContainer',
    alias: 'widget.phonefieldcontainer',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'displayfield',
                    value: '(',
                    flex: 0
                },
                {
                    xtype: 'numberfield',
                    margin: '0 1',
                    width: 50,
                    name: 'areacode',
                    hideTrigger: true,
                    minValue: 0,
                    allowBlank: false
                },
                {
                    xtype: 'displayfield',
                    value: ')',
                    flex: 0
                },
                {
                    xtype: 'numberfield',
                    margin: '0 1',
                    width: 150,
                    name: 'phnumber',
                    hideTrigger: true,
                    minValue: 0,
                    allowBlank: false
                },
                {
                    xtype: 'numberfield',
                    margin: '0 15 0 0',
                    width: 105,
                    name: 'extension',
                    fieldLabel: 'Ext',
                    labelAlign: 'right',
                    labelWidth: 50,
                    hideTrigger: true
                },
                {
                    xtype: 'countrycombo',
                    name: 'countryiso',
                    fieldLabel: 'Country',
                    labelAlign: 'right',
                    labelWidth: 50,
                    flex: 1,
                    allowBlank: false
                },
                {
                    xtype: 'hiddenfield',
                    itemId: 'recordId',
                    name: 'phoneid',
                    fieldLabel: 'Label',
                    flex: 1
                }
            ]
        });

        me.callParent(arguments);
    }
});
