/**
 * Controller for ContactList
 */
Ext.define('PTS.controller.contact.tab.ContactList', {
    extend: 'Ext.app.Controller',
    stores: [
        'Persons',
        'ContactGroups'
    ],
    views: [
        'contact.PersonList',
        'contact.GroupList',
        'contact.tab.ContactTab'
    ],
    refs: [{
        ref: 'contactLists',
        selector: 'contacttab > #contactList'
    }/*,{
        ref: 'personList',
        selector: 'contacttab > personlist'
    }*/],

    init: function() {

       this.control({
            'contacttab personlist': {
                itemdblclick: this.editContact,
                viewready: this.onContactListReady,
                selectionchange: this.onContactListSelect,
                activate: this.onContactListActivate
            },
            'contacttab grouplist': {
                itemdblclick: this.editContact,
                viewready: this.onContactListReady,
                selectionchange: this.onContactListSelect,
                activate: this.onContactListActivate
            }
        });

        // We listen for the application-wide events
        this.application.on({
            savecontact: this.onSaveContact,
            deletecontact: this.onDeleteContact,
            scope: this
        });

    },

    /**
     * Get the active contact grid.
     */
    getContactList: function() {
        var tp = this.getContactLists();

        return tp.getActiveTab();
    },

    editContact: function(grid, record) {
        var pc = this.getController('contact.Contact'),
        type = record.getContactType();

        pc.openContact(type, record);
    },

    onContactListReady: function(grid) {
        var store = grid.getStore();
        if (store) {
            store.on('load', function(store, records, success, oper){
                if(store.count() > 0) {
                    this.getSelectionModel().select(0);
                }
            },grid);
        }
        store.load();
    },

    onContactListSelect: function(selModel, selection) {
        this.application.fireEvent('contactlistselect', selection[0]);
    },

    onContactListActivate: function(grid) {
        this.application.fireEvent('contactlistactivate', grid);
    },

    onSaveContact: function(record, op) {
        var store, index, copy,
            id = record.getId(),
            type = record.getContactType();

        switch(type) {
            case 'person':
              store = this.getPersonsStore();
              break;
            case 'group':
              store = this.getContactGroupsStore();
              break;
        }

        index = store.indexOfId(id);

        if(index === -1) {
        //We assume grid and form are using the same model,
        //This might change in the future. If so, this data would
        //need to be copied to the gridstore model instead of inserted.
            store.insert(0,record);
        } else {
        //The record exists in the store, so copy the data
            copy = store.getAt(index);
            copy.fields.each(function(field) {
                copy.set(field.name,record.get(field.name));
            });
            copy.commit();
        }
    },

    /**
     * Fired when a contact is deleted.
     * No record is passed(null), so we
     * need to use the operation records array
     */
    onDeleteContact: function(record, op) {
        var store,
            type = op.records[0].getContactType();

        switch(type) {
            case 'person':
              store = this.getPersonsStore();
              break;
            case 'group':
              store = this.getContactGroupsStore();
              break;
        }

        Ext.each(op.records, function(rec) {
            var id = rec.getId();

            store.remove(store.getById(id));
        });
    }
});
