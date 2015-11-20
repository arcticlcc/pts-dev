/**
 * Base Controller for Modification Forms (agreement, proposal, modification)
 */
Ext.define('PTS.controller.project.form.BaseModificationForm', {
    extend: 'Ext.app.Controller',

    /*views: [
        'project.form.AgreementForm'
    ],*/
    models: [
        'ModificationContact'
    ],
    stores: [
        'PurchaseRequests',
        'Statuses',
        'ModStatuses'
    ],
    /*
        refs: [{
            ref: 'agreementForm',
            selector: 'agreementform#itemCard-20'
        }],*/

    init: function() {
        /*this.control({
            'agreementform #statusGrid': {
                validateedit: this.validateStatus
            }
        });*/

        /*// We listen for the application-wide loaditem event
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });*/

    },

    /**
     * Get the contactsForm
     */
    getContactsForm: function() {
        var form = this.getAgreementCard().down('#relatedDetails>form#contactsForm');
        return form;
    },

    /**
     * Disable the related details panel and clear any related grid stores.
     */
    onNewItem: function(model, form) {
        //we have to check the itemId since this controller is extended by project.form.{Modification|Proposal}Form
        // and we don't want to fire multiple times
        if (this.getAgreementCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid'),
                contactsForm = this.getContactsForm();

            form.ownerCt.down('#relatedDetails').disable();
            Ext.each(grids, function(gr) {
                gr.getStore().removeAll();
            });

            //unbind form record
            delete contactsForm.getForm().reset()._record;
        }
    },

    /**
     * Load the active roweditgrid, if any. Clear the other stores.
     * Set the statuscombo baseFilter.
     * TODO: probably should use associations for this
     */
    onItemLoad: function(model, form) {
        var statusStore = this.getStatusesStore(),
            bFilter = [{
                id: "type",
                property: "modtypeid",
                value: model.get('modtypeid'),
                exactMatch: true
            }];

        //we have to check the itemId since this controller is extended by project.form.{Modification|Proposal}Form
        // and we don't want to fire multiple times
        if (this.getAgreementCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid'),
                id = model.getId(),
                contactsForm = this.getContactsForm(),
                contactModel = this.getModel('ModificationContact');

            Ext.each(grids, function(gr) {
                var store = gr.getStore();

                if (gr.tab.active) {
                    this.updateDetailStore(store, id, gr.uri);
                    store.load({
                        callback: function(rec, op, success) {
                            if (success) {
                                gr.up('#relatedDetails').enable();
                            }
                        },
                        scope: gr
                    });
                } else {
                    store.removeAll();
                }
            }, this);

            if (id) {
                contactModel.load(id, { // load with id from modification
                    success: function(model) {
                        contactsForm.loadRecord(model);
                    }
                });
            }

            //set the baseFilter on the statuscombo
            form.ownerCt.down('#relatedDetails gridcolumn[dataIndex=statusid]').getEditor().baseFilter = bFilter;

            //filter the Statuses store
            statusStore.clearFilter();
            statusStore.filter(bFilter);
            statusStore.sort('weight');

        }
    },

    /**
     * Update the record in the roweditgrid store with the modificationid.
     */
    onDetailRowEdit: function(editor, e) {
        var model = this.getAgreementForm().getRecord(),
            id = model.getId();

        editor.record.set('modificationid', id);
        editor.store.sync();

    },

    /**
     * Update the activated roweditgrid store with current the modificationid.
     */
    onDetailActivate: function(grid) {
        var model = this.getAgreementForm().getRecord(),
            store, id;

        if (model !== undefined) {
            store = grid.getStore();
            //only load if the store is not loading
            if (!store.isLoading() && store.count() === 0) {
                id = model.getId();
                this.updateDetailStore(store, id, grid.uri);
                store.load();
            }
        }
    },

    /**
     * Update the roweditgrid store with the passed modificationid.
     */
    updateDetailStore: function(store, id, uri) {

        //override store proxy based on modificationid
        store.setProxy({
            type: 'rest',
            url: '../' + uri,
            //appendId: true,
            api: {
                read: '../modification/' + id + '/' + uri
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
    },

    /**
     * Validate the agreement status.
     */
    validateStatus: function(editor, e) {
        var newStatus = e.newValues.statusid;

        if (newStatus === 2 && newStatus !== e.originalValues.statusid) {
            var modId = this.getAgreementForm().getRecord().getId(),
                rec = e.record,
                ctl = this,
                mask = new Ext.LoadMask(e.grid, {
                    msg: "Validating. Please wait..."
                });

            mask.show();
            //query database for incomplete deliverables
            Ext.Ajax.request({
                url: '../deliverablestatuslist',
                params: {
                    filter: '[{"property":"deliverablestatusid","value":["<",40]},{"property":"modificationid","value":' + modId + '}]'
                },
                method: 'GET',
                success: function(response) {
                    var data = Ext.JSON.decode(response.responseText);

                    //if records are found, raise error and cancel the update
                    if (data.total > 0) {
                        e.column.getEditor().markInvalid('This agreement has incomplete deliverables.');
                        Ext.create('widget.uxNotification', {
                            title: 'Error',
                            iconCls: 'ux-notification-icon-error',
                            html: 'This agreement has incomplete deliverables.'
                        }).show();
                    } else {
                        //no errors, save the record
                        editor.getEditor().completeEdit();
                        ctl.onDetailRowEdit(e);
                        //rec.set('modificationid',modId);
                        //rec.save();
                    }
                    mask.destroy();
                },
                failure: function() {
                    mask.destroy();
                    Ext.create('widget.uxNotification', {
                        title: 'Error',
                        iconCls: 'ux-notification-icon-error',
                        html: 'There was an error validating the status entry. </br>Error:' + PTS.app.getError()
                    }).show();
                },
                scope: this
            });

            //we have to handle the update manually after the response is returned
            return false;
        }
    },
    /**
     * Reset button click handler for contact form.
     */
    clickContactReset: function(btn) {
        this.getContactsForm().getForm().reset();
    },

    /**
     * Save button click handler for contact form.
     */
    clickContactSave: function(btn) {
        var form = this.getContactsForm().getForm(),
            el = this.getContactsForm().getEl(),
            record = form.getRecord();

        el.mask('Saving...');
        form.updateRecord(record);
        record.save({
            success: function(model, op) {
                var form = this.getContactsForm();

                //load the model to get desired trackresetonload behavior
                form.loadRecord(model);
                el.unmask();
            },
            failure: function(model, op) {
                el.unmask();
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'There was an error saving the contacts.</br>Error: ' + PTS.app.getError()
                }).show();
            },
            scope: this
        });
    },
    /**
     * Update modification contacts fromField.
     */
    updateContacts: function(store) {
        var field = this.getContactsForm().down('itemselector');

        if (field.rendered) {
            field.bindStore(store);
            field.setRawValue(field.rawValue);
        }
    }
});
