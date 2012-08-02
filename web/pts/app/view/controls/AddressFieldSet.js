/**
 * Address fieldset
 */
Ext.define('PTS.view.controls.AddressFieldSet', {
    extend: 'PTS.view.controls.MyFieldSet',
    alias: 'widget.addressfieldset',
    requires: [
        'PTS.view.controls.StateCombo',
        'PTS.view.controls.CountryCombo'
    ],

    cls: 'pts-contact-fieldset',
    itemId: 'address',
    margin: '10 0 0 0',
    checkboxName: 'addressCbx',
    checkboxToggle: true,
    collapsed: true,
    collapsible: true,
    title: 'Address',

    /**
     * @cfg {Boolean/String}
     * This controls whether the copy checkbox is rendered into the fieldset
     * Supplying anything other than a false value will render the checkbox with
     * the passed value as the itemId.
     */
    copyCheckBox: false,

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
                    xtype: 'textfield',
                    name: 'street1',
                    fieldLabel: 'Street 1',
                    allowBlank: false,
                    anchor: '100%'
                },
                {
                    xtype: 'textfield',
                    name: 'street2',
                    fieldLabel: 'Street 2',
                    anchor: '100%'
                },
                {
                    xtype: 'fieldcontainer',
                    layout: {
                        align: 'middle',
                        defaultMargins: {
                            'top': 0,
                            right: 5,
                            bottom: 0,
                            left: 0
                        },
                        type: 'hbox'
                    },
                    items: [
                        {
                            xtype: 'textfield',
                            itemId: 'city',
                            disabled: true,
                            width: 400,
                            name: 'city',
                            fieldLabel: 'City',
                            allowBlank: false,
                            flex: 0
                        },
                        {
                            xtype: 'statecombo',
                            itemId: 'state',
                            disabled: true,
                            width: 400,
                            name: 'stateid',
                            fieldLabel: 'State',
                            allowBlank: false,
                            labelAlign: 'right',
                            labelWidth: 75,
                            flex: 0
                        }
                    ]
                },
                {
                    xtype: 'fieldcontainer',
                    layout: {
                        align: 'middle',
                        defaultMargins: {
                            'top': 0,
                            right: 5,
                            bottom: 0,
                            left: 0
                        },
                        type: 'hbox'
                    },
                    items: [
                        {
                            xtype: 'countrycombo',
                            itemId: 'country',
                            width: 400,
                            name: 'countryiso',
                            fieldLabel: 'Country',
                            allowBlank: false
                        },
                        {
                            xtype: 'textfield',
                            itemId: 'postalcode',
                            width: 200,
                            name: 'postalcode',
                            fieldLabel: 'Zip code',
                            allowBlank: false,
                            labelAlign: 'right',
                            labelWidth: 75,
                            flex: 0
                        },
                        {
                            xtype: 'textfield',
                            width: 130,
                            name: 'postal4',
                            fieldLabel: 'Zip4',
                            labelAlign: 'right',
                            labelWidth: 60,
                            flex: 0
                        }
                    ]
                },
                {
                    xtype: 'hiddenfield',
                    itemId: 'recordId',
                    name: 'addressid',
                    fieldLabel: 'Label',
                    anchor: '100%'
                }
            ];

        if(me.deleteCheckBox) {
            itms.splice(0,0,{
                xtype: 'checkboxfield',
                itemId: me.deleteCheckBox,
                disabled: true,
                hideEmptyLabel: false,
                boxLabel: 'Delete address',
                anchor: '100%',
                listeners: {
                    change: this.deleteCheckBoxAction
                }
            });
        }
        if(me.copyCheckBox) {
            itms.splice(0,0,{
                xtype: 'checkboxfield',
                itemId: me.copyCheckBox,
                hideEmptyLabel: false,
                boxLabel: 'Copy primary mailing address',
                anchor: '100%'
            });
        }

        Ext.applyIf(me, {
            items: itms
        });

        me.callParent(arguments);
    }
});
