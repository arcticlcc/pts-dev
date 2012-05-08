/**
 * Generic combo box for country states.
 * Currently the database only supports US, Canada.
 * If the combo is included in a {PTS.view.controls.AddressFieldSet},
 * the combo will be filtered by the country value.
 */
Ext.define('PTS.view.controls.StateCombo', {
    extend: 'PTS.view.controls.FilterCombo',
    alias: 'widget.statecombo',
    requires: ['PTS.store.States', 'Ext.form.field.ComboBox'],

    name: 'stateid',
    fieldLabel: 'State',
    //anchor: '50%',
    store: 'States', //Ext.create('PTS.store.States'),
    displayField: 'statename',
    valueField: 'stateid',
    forceSelection: true,
    allowBlank: false,
    queryMode: 'local',
    lastQuery: '',

    initComponent: function() {
        var me = this;
        me.callParent(arguments);

        me.baseFilter = [
            {
                filterFn: function(item) {
                    var c = me.up('addressfieldset').down('countrycombo').getValue();
                    return item.get('countryalpha') === c;
                }
            }
        ];
    }
});
