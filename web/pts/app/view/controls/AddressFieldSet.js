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

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
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
            ]
        });

        me.callParent(arguments);
    },

    listeners: {
        beforerender: function(cmp) {
            if(cmp.copyCheckBox) {
                cmp.insert(0,{
                    xtype: 'checkboxfield',
                    itemId: cmp.copyCheckBox,
                    hideEmptyLabel: false,
                    boxLabel: 'Copy primary mailing address',
                    anchor: '100%'
                });
            }
        }
    }
});
