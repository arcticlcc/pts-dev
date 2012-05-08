/**
 * Combo box that lists countries.
 */
Ext.define('PTS.view.controls.CountryCombo', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.countrycombo',
    requires: ['PTS.store.Countries'],

    name: 'countryid',
    fieldLabel: 'Country',
    //anchor: '50%',
    store: 'Countries',
    displayField: 'country',
    valueField: 'countryid',
    value: 'US', //default value
    forceSelection: true,
    allowBlank: false,
    queryMode: 'local',

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
    }
});
