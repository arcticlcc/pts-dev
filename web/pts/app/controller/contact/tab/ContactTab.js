/**
 * Controller for ContactTab
 */
Ext.define('PTS.controller.contact.tab.ContactTab', {
    extend: 'Ext.app.Controller',

    views: [
        'contact.tab.ContactTab'
    ],

    refs: [{
        ref: 'personList',
        selector: 'contacttab > personlist'
    }, {
        ref: 'contactTab',
        selector: 'contacttab'
    }],

    init: function() {

        var list = this.getController('contact.tab.ContactList'),
            det = this.getController('contact.tab.ContactTabDetail');

        // Remember to call the init method manually
        list.init();
        det.init();

        this.control({
            'contacttab button[action=addcontact]': {
                click: this.newContact
            },

            'contacttab button[action=editcontact]': {
                click: this.editContact
            }
        });

        // We listen for the application-wide events
        this.application.on({
            contactlistselect: this.onContactListSelect,
            contactlistactivate: this.onContactListActivate,
            scope: this
        });

    },

    newContact: function() {
        var pc = this.getController('contact.Contact'),
            cl = this.getController('contact.tab.ContactList'),
            type = cl.getContactList().getItemId();

        pc.openContact(type);
    },

    editContact: function() {
        var pc = this.getController('contact.Contact'),
            cl = this.getController('contact.tab.ContactList'),
            record = cl.getContactList().getSelectionModel().getSelection()[0],
            type = record.getContactType();
        if (record) {
            pc.openContact(type, record);
        }
    },

    onContactListSelect: function(selected) {
        this.getContactTab().down('button[action=editcontact]').setDisabled(!selected);
    },

    onContactListActivate: function(grid) {
        var count = grid.getSelectionModel().getCount();

        this.getContactTab().down('button[action=editcontact]').setDisabled(!count);
    }
});
