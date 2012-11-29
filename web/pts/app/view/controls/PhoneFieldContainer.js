/**
 * Fieldcontainer configured for phone numbers
 */
Ext.define('PTS.view.controls.PhoneFieldContainer', {
    extend: 'PTS.view.controls.MyFieldContainer',
    alias: 'widget.phonefieldcontainer',
    requires: [
        'Ext.form.field.Display'
    ],

    /**
     * @cfg {Boolean/String}
     * This controls whether the delete checkbox is rendered into the fieldset
     * Supplying anything other than a false value will render the checkbox with
     * the passed value as the itemId.
     */
    deleteCheckBox: 'delete',

    /**
     * A function to run when the delete checkbox is clicked. By default
     * the field labels in the parent container will be highlighted when the
     * box is checked. Override to customize the action.
     * @param {Ext.form.field.Checkbox} cbx The checkbox.
     * @param {Object} newValue The new value
     * @param {Object} oldValue The original value
     */
    deleteCheckBoxAction: function(cbx, newValue, oldValue) {
        var clr = newValue ? '#C62415' : 'inherit';

        cbx.ownerCt.getEl().setStyle({
            color: clr
        });
    },

    initComponent: function() {
        var me = this,
            itms = [
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
                    name: 'phoneid'
                }
            ];

        if(me.deleteCheckBox) {
            itms.push({
                xtype: 'checkboxfield',
                itemId: me.deleteCheckBox,
                disabled: true,
                hideEmptyLabel: false,
                boxLabel: 'Delete',
                labelWidth: 10,
                listeners: {
                    change: this.deleteCheckBoxAction
                }
            });
        }

        Ext.applyIf(me, {
            items: itms
        });

        me.callParent(arguments);

    }
});
