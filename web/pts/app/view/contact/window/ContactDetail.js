/**
 * @class PTS.view.contact.window.ContactDetail
 * TODO: create countrycombo, statecombo controls
 */
Ext.define('PTS.view.contact.window.ContactDetail', {
    extend: 'Ext.container.Container',
    alias: 'widget.contactdetail',
    requires: [
        'PTS.view.controls.MyFieldContainer',
        'PTS.view.controls.AddressFieldSet',
        'Ext.form.field.Hidden'
    ],

    margin: '0 0 10 0',
    layout: {
        type: 'anchor'
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'myfieldcontainer',
                    itemId: 'emailAddress',
                    layout: {
                        type: 'fit'
                    },
                    anchor: '75%',
                    items: [
                        {
                            xtype: 'textfield',
                            name: 'uri',
                            fieldLabel: 'Primary E-mail',
                            vtype: 'email'
                        },
                        {
                            xtype: 'hiddenfield',
                            itemId: 'recordId',
                            name: 'eaddressid',
                            fieldLabel: 'Label'
                        }
                    ]
                },
                {
                    xtype: 'myfieldcontainer',
                    itemId: 'webAddress',
                    layout: {
                        type: 'fit'
                    },
                    anchor: '75%',
                    items: [
                        {
                            xtype: 'textfield',
                            name: 'uri',
                            fieldLabel: 'Website',
                            vtype: 'url'
                        },
                        {
                            xtype: 'hiddenfield',
                            itemId: 'recordId',
                            name: 'eaddressid',
                            fieldLabel: 'Label'
                        }
                    ]
                },
                {
                    xtype: 'addressfieldset',
                    cls: 'pts-contact-fieldset',
                    itemId: 'mailAddress',
                    margin: '10 0 0 0',
                    checkboxName: 'mailingCbx',
                    checkboxToggle: true,
                    collapsed: true,
                    collapsible: true,
                    title: 'Primary Mailing Address'
                },
                {
                    xtype: 'addressfieldset',
                    cls: 'pts-contact-fieldset',
                    itemId: 'physicalAddress',
                    copyCheckBox: 'sameAddCbx',
                    margin: '10 0 0 0',
                    checkboxName: 'physicalCbx',
                    checkboxToggle: true,
                    collapsed: true,
                    collapsible: true,
                    title: 'Primary Physical Address'
                },
                {
                    xtype: 'myfieldset',
                    cls: 'pts-contact-fieldset',
                    itemId: 'phoneNumbers',
                    margin: '10 0 0 0',
                    checkboxName: 'phoneCbx',
                    checkboxToggle: true,
                    collapsed: true,
                    collapsible: true,
                    title: 'Phone',
                    items: [
                        {
                            xtype: 'myfieldcontainer',
                            itemId: 'officePhone',
                            layout: {
                                align: 'middle',
                                type: 'hbox'
                            },
                            fieldLabel: 'Office',
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
                                    minValue: 0
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
                                    minValue: 0
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
                                    flex: 1
                                },
                                {
                                    xtype: 'hiddenfield',
                                    itemId: 'recordId',
                                    name: 'phoneid',
                                    fieldLabel: 'Label',
                                    flex: 1
                                }
                            ]
                        },
                        {
                            xtype: 'myfieldcontainer',
                            itemId: 'mobilePhone',
                            layout: {
                                align: 'middle',
                                type: 'hbox'
                            },
                            fieldLabel: 'Mobile',
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
                                    minValue: 0
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
                                    minValue: 0
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
                                    flex: 1
                                },
                                {
                                    xtype: 'hiddenfield',
                                    itemId: 'recordId',
                                    name: 'phoneid',
                                    fieldLabel: 'Label',
                                    flex: 1
                                }
                            ]
                        },
                        {
                            xtype: 'myfieldcontainer',
                            itemId: 'faxPhone',
                            layout: {
                                align: 'middle',
                                type: 'hbox'
                            },
                            fieldLabel: 'Fax',
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
                                    minValue: 0
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
                                    minValue: 0
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
                                    flex: 1
                                },
                                {
                                    xtype: 'hiddenfield',
                                    itemId: 'recordId',
                                    name: 'phoneid',
                                    fieldLabel: 'Label',
                                    flex: 1
                                }
                            ]
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
