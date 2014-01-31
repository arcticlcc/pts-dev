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
    listConfig: {
        getInnerTpl: function() {
            return '<span <tpl if="inactive">style="color:gray;"</tpl>>{fullname}</span>';
        }
    },
    listeners: {
        beforeselect: {
            fn: function(combo, rec){
                if(rec.get('inactive')) {return false;}
            }
        }
    },

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
    }
});
