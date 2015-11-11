/**
 * Combobox that lists status for proposals, modifications, and agreements.
 */
Ext.define('PTS.view.controls.StatusCombo', {
    extend: 'PTS.view.controls.FilterCombo',
    alias: 'widget.statuscombo',
    requires: ['PTS.store.Statuses', 'Ext.form.field.ComboBox'],

    displayField: 'code',
    store: 'Statuses',
    valueField: 'statusid',
    forceSelection: true,
    typeAhead: false,
    queryMode: 'local',
    lastQuery: '',

    listConfig: {
        getInnerTpl: function() {
            return '<div data-qtip="{description}">{code}</div>';
        }
    },

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
    }
});
