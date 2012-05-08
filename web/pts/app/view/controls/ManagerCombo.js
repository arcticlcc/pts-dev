/**
 * Combobox that lists members of the current user's group.
 */
Ext.define('PTS.view.controls.ManagerCombo', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.managercombo',

    name: 'personid',
    fieldLabel: 'Manager',
    //anchor: '50%',
    store: 'GroupUsers',
    displayField: 'fullname',
    valueField: 'contactid',
    forceSelection: true,
    allowBlank: false,
    queryMode: 'local',

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
    }
});
