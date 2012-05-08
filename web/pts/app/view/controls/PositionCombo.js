/**
 * Combobox that lists positions for persons.
 */
Ext.define('PTS.view.controls.PositionCombo', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.positioncombo',
    requires: ['PTS.store.Positions'],

    name: 'positionid',
    fieldLabel: 'Position',
    //anchor: '50%',
    store: 'Positions',
    displayField: 'title',
    valueField: 'positionid',
    forceSelection: true,
    allowBlank: false,
    queryMode: 'local',

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
    }
});
