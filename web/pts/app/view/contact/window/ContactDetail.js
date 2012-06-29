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
        'Ext.form.field.Hidden',
        'PTS.view.controls.PhoneFieldContainer'
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
                            xtype: 'phonefieldcontainer',
                            itemId: 'officePhone',
                            layout: {
                                align: 'middle',
                                type: 'hbox'
                            },
                            fieldLabel: 'Office'
                        },
                        {
                            xtype: 'phonefieldcontainer',
                            itemId: 'mobilePhone',
                            layout: {
                                align: 'middle',
                                type: 'hbox'
                            },
                            fieldLabel: 'Mobile'
                        },
                        {
                            xtype: 'phonefieldcontainer',
                            itemId: 'faxPhone',
                            layout: {
                                align: 'middle',
                                type: 'hbox'
                            },
                            fieldLabel: 'Fax'
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
