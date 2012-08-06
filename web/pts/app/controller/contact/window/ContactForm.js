/**
 * The Contact Form controller
 */
Ext.define('PTS.controller.contact.window.ContactForm', {
    extend: 'Ext.app.Controller',

    views: [
        'contact.window.ContactForm',
        'contact.window.PersonGroups'
    ],
    models: [
        'Person',
        'ContactGroup',
        'Address',
        'EAddress',
        'Phone'
    ],
    stores: [
        'ContactTypes',
        'ContactContactGroups',
        'ContactGroups',
        'DDContactGroups',
        'Persons',
        'DDPersons'
    ],
    refs: [{
        ref: 'contactForm',
        selector: 'contactform'
    }],

    init: function() {

        var pg = this.getController('contact.window.PersonGroups'),
            cd = this.getController('contact.window.ContactDetail');

        // Remember to call the init method manually
        pg.init();
        cd.init();

        this.control({
            'contactform button[action=savecontact]': {
                click: this.saveContact
            },
            'contactform button[action=resetcontact]': {
                click: this.resetContact
            },
            'contactform button[action=deletecontact]': {
                click: this.confirmDelete
            }
        });

        // We listen for the application-wide opencontact event
        this.application.on({
            opencontact: this.onOpenContact,
            scope: this
        });
    },

    /**
     * Return the active (visible) form.
     * @returns {Ext.Component} The active form panel.
     */
    getActiveForm: function() {
        return this.getContactForm().getLayout().getActiveItem().down('form');
    },

    /**
     * Return the appropriate model for the active (visible) form.
     *
     * TODO: probably should pass this a form object with the model set as a property to avoid switch statement
     * @returns {Ext.data.Model}
     */
    getActiveModel: function() {
        var form = this.getActiveForm();

        switch(form.getItemId()) {
            case 'personForm':
              return this.getPersonModel();
            case 'groupForm':
              return this.getContactGroupModel();
            default:
              Ext.Error.raise('No model found for item!');
        }
    },

    /**
     * Stuff to do when the opencontact event is fired.
     * @param {Number/Boolean} id The id of the record to load or **false** if a new record.
     * @param {Ext.Component/Number/String} type The card, itemId, or index to load.
     *
     * - **0** : **Default** Person form
     * - **1** : Group form
     */
    onOpenContact: function(id, type) {
        var cnt = this.getContactForm(),
            tab, cfg, setItem;

        switch(type) {
            case 'person':
                cfg = {
                    title: 'Manage Groups',
                    disabled: !id
                };
                break;
            case 'group':
                cfg = {
                    title: 'Manage Members',
                    disabled: !id
                };
                break;
        }

        tab = Ext.create('PTS.view.contact.window.PersonGroups',cfg);

        setItem = function() {
            cnt.getLayout().setActiveItem(type);
            this.loadRecord(id);
            //add the persongroup tab
            cnt.getLayout().getActiveItem().add(tab);

        };

        //make sure the card container is rendered
        if(cnt.rendered) {
            setItem.call(this);
        } else {
            cnt.on('render',setItem, this, {
                single: true
            });
        }
    },

    /**
     * @event
     * Save contact event.
     */
    onSaveContact: function(record, op) {
        this.application.fireEvent('savecontact', record, op);
    },

    /**
     * @event
     * Delete contact event.
     */
    onDeleteContact: function(record, op) {
        this.application.fireEvent('deletecontact', record, op);
    },

    /**
     * @event
     * Load contact event.
     */
    onLoadContact: function(form, model) {
        this.application.fireEvent('loadcontact', form, model);
    },

    /**
     * Save contact detail fieldset record.
     */
    saveFieldSet: function(store, fieldset, type) {
        var itmRec, itmId,
            save = fieldset.isDirty() && fieldset.isValid();
        //we only save if valid and dirty
        if(save) {
            itmId = parseInt(fieldset.down('#recordId').getValue(), 10);

            if(itmRec = store.getById(itmId)) {
                //load the new data into existing model
                    itmRec.beginEdit();
                        Ext.each(fieldset.query('field'), function() {
                            itmRec.set(this.name, this.getValue());
                        });
                    itmRec.endEdit();

            }else{ //we need to create a new record
                    var cfg = {};

                    Ext.each(fieldset.query('field'), function() {
                        cfg[this.name] = this.getValue();
                    });
                    Ext.applyIf(cfg,type);
                    itmRec = store.add(cfg);
                    itmRec[0].setDirty();
            }
        }
    },

    /**
     * Delete contact detail fieldset record.
     */
    deleteFieldSet: function(store, fieldset) {
        var itmRec, itmId, del;

            itmId = parseInt(fieldset.down('#recordId').getValue(), 10);

            if(itmRec = store.getById(itmId)) {
                store.remove(itmRec);
            }
            //disable the checkbox
            if(del = fieldset.down('checkboxfield#delete')) {
                del.disable();
            }
    },

    /**
     * Save all contact detail fieldsets to the model.
     */
    saveAllFieldSets: function(pnl, frm, rec) {
        var panel = pnl ? pnl : this.getActiveForm(),
            form = frm ? frm : panel.getForm(),
            record = rec ? rec : form.getRecord(),
            store,fieldset,
            phone = [
                {type:'fax',val:'1'},
                {type:'office',val:'3'},
                {type:'mobile',val:'2'}
            ],
            address = [
                {type:'mail',val:'1'},
                {type:'physical',val:'2'}
            ],
            eaddress = [
                {type:'web',val:'2'},
                {type:'email',val:'1'}
            ];

        //update the details
        Ext.each(address, function(itm){
            store = record.addresses();
            fieldset = panel.down('fieldset#' + itm.type + 'Address');
            //check the status of the delete checkbox
            if(fieldset.down('checkboxfield#delete').getValue()) {
                this.deleteFieldSet(store, fieldset);
            }else {
                this.saveFieldSet(store, fieldset, {addresstypeid: itm.val});
            }
        },this);

        Ext.each(eaddress, function(itm){
            store = record.eaddresses();
            fieldset = panel.down('fieldcontainer#' + itm.type + 'Address');
            //delete the record if the field is empty
            if(Ext.String.trim(fieldset.down('textfield[name=uri]').getValue()) === '' && fieldset.isDirty()) {
                this.deleteFieldSet(store, fieldset);
            }else {
                this.saveFieldSet(store, fieldset, {eaddresstypeid: itm.val});
            }
        },this);

        Ext.each(phone, function(itm){
            store = record.phones();
            fieldset = panel.down('fieldcontainer#' + itm.type + 'Phone');

            if(fieldset.down('checkboxfield#delete').getValue()) {
                this.deleteFieldSet(store, fieldset);
            }else {
                this.saveFieldSet(store, fieldset, {phonetypeid: itm.val});
            }
        },this);
    },

    //TODO: fire app events to reload contact list, etc.
    //TODO: remove hardcoded values for detail type IDs, use stores
    /**
     * Save contact.
     */
     saveContact: function() {
        var panel = this.getActiveForm(),
            form = panel.getForm(),
            record = form.getRecord();

        //mask the form
        panel.getEl().mask('Saving...');
        //update the main record
        form.updateRecord(record);
        //update the details
        this.saveAllFieldSets(panel, form, record);

        record.save({
            success: function(model, op) {
                //clear fields to remove old/invalid data
                Ext.each(panel.query('field'),function(){
                    this.setValue('');
                    this.clearInvalid();
                });
                form.loadRecord(model); //load the model
                this.loadRecordDetails(model, panel); //load the details
                //reset all the original values to get desired trackresetonload behaviour
                Ext.each(this.getActiveForm().query('field'), function() {
                    this.resetOriginalValue();
                });

                this.onSaveContact(model, op);

                panel.getEl().unmask();
            },
            failure: function(model, op) {
                //TODO: clean out phantom associated records to prevent duplicates
                if(record.associations.items.length) {//check for associations
                    //loop thru associations
                    record.associations.each(function(assoc){
                        var store = record[assoc.name]();
                        //and get phantom records
                        store.remove(store.getNewRecords());

                    },this);
                }

                panel.getEl().unmask();
                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'There was a problem saving the contact.</br>' + PTS.app.getError(),
                   buttons: Ext.MessageBox.OK,
                   animateTarget: panel.down('button[action=savecontact]').getEl(),
                   //fn: showResult,
                   icon: Ext.Msg.ERROR
               });
            },
            scope: this //need the controller to load the model on success
        });
     },

    /**
     * Confirm contact deletion.
     */
    confirmDelete: function(btn) {
        var el = btn.getEl(),
            del = function(b) {
                if('yes' === b) {
                    this.deleteContact();
                }
            };

        Ext.MessageBox.show({
            title: 'Confirm Deletion',
            msg: 'Are you sure you want to delete this contact?',
            //width:300,
            buttons: Ext.MessageBox.YESNO,
            icon: Ext.Msg.WARNING,
            fn: del,
            scope: this,
            animateTarget: el
        });
    },

    /**
     * Delete contact.
     */
     deleteContact: function() {
        var form = this.getActiveForm().getForm(),
        record = form.getRecord();

        record.destroy({
            success: function(model, op) {
                this.onDeleteContact(model, op);
                this.getContactForm().up('window').close();
            },
            /*failure: function(model, op) {

                Ext.MessageBox.show({
                   title: 'Error',
                   msg: 'There was an error.',
                   buttons: Ext.MessageBox.OK,
                   //animateTarget: 'mb9',
                   //fn: showResult,
                   icon: Ext.Msg.ERROR
               });
            },*/
            scope: this //need the controller
        });
     },

    /**
     * Reset contact form.
     */
     resetContact: function() {
        var panel = this.getActiveForm(),
            form = panel.getForm(),
            record = form.getRecord();

        //we need to reject the changes to the associated records
        //TODO: handle association rejections in the base model class
        if(record.associations.items.length) {//check for associations
            //loop thru associations
            record.associations.each(function(assoc){
                var store = record[assoc.name]();

                store.rejectChanges();
            });
        }
        record.reject();

        form.reset();
     },

    /**
     * Load contact detail fieldset.
     */
    loadFieldSet: function(rec, fieldSet, cbx) {
        var del = fieldSet.items.get('delete');

        if(cbx) {
            cbx.setValue(true);
            cbx.resetOriginalValue();
        }
        Ext.each(fieldSet.query('field'), function() {
            var me = this,
                val,
                name = this.getName();

            if(undefined !== (val = rec.get(name))) {
                me.setValue(val);
                me.resetOriginalValue();
            }
        });
        //show delete checkbox
        if(del) {
            del.enable();
        }
    },

    /**
     * Load contact.
     */
    loadRecord: function(id) {
        var model = this.getActiveModel(),
            form = this.getActiveForm();
        if(id) {
            form.getEl().mask('Loading...');
            model.load(id, { // load with id from selected record
                success: function(model) {
                    /*var addRec, addSet, addCbx,
                        phone = [
                            {type:'fax',val:'1'},
                            {type:'office',val:'3'},
                            {type:'mobile',val:'2'}
                        ],
                        eaddress = [
                            {type:'web',val:'2'},
                            {type:'email',val:'1'}
                        ];*/
                    form.loadRecord(model); // when model is loaded successfully, load the data into the form
                    this.loadRecordDetails(model, form);
                    //load the contact details
                    //TODO: implement "primary" filtering client-side
                    //Allow management of additional addresses & phone#s
                    /*if(model.addresses().count()) {//load addresses
                        //mailing address
                        if(addRec = model.addresses().findRecord( 'addresstypeid',1)) {
                            addSet = form.down('fieldset#mailAddress');
                            addCbx = addSet.down('checkbox[name=mailingCbx]');
                            this.loadFieldSet(addRec, addSet, addCbx);
                        }
                        //physical address
                        if(addRec = model.addresses().findRecord( 'addresstypeid',2)) {
                            addSet = form.down('fieldset#physicalAddress');
                            addCbx = addSet.down('checkbox[name=physicalCbx]');
                            this.loadFieldSet(addRec, addSet, addCbx);
                        }
                    }

                    if(model.phones().count()) {//load phones
                        addCbx = form.down('checkbox[name=phoneCbx]');
                        Ext.each(phone, function(itm){
                            if(addRec = model.phones().findRecord( 'phonetypeid',itm.val)) {
                                addSet = form.down('fieldcontainer#' + itm.type + 'Phone');
                                this.loadFieldSet(addRec, addSet, addCbx);
                            }
                        },this);
                    }

                    if(model.eaddresses().count()) {//load electronic addresses
                        Ext.each(eaddress, function(itm){
                            if(addRec = model.eaddresses().findRecord( 'eaddresstypeid',itm.val)) {
                                addSet = form.down('fieldcontainer#' + itm.type + 'Address');
                                this.loadFieldSet(addRec, addSet);
                            }
                        },this);
                    }*/
                    /*Ext.each(itemCard.query('field'), function() {// set all fields as read-only on load
                        this.setReadOnly(true);
                    });
                    itemDetail.setIconCls('alcc-panel-locked');//set the lock icon on the panel

                    Ext.each(btns, function(){
                        this.enable();
                    });
                    itemDetail.getLayout().setActiveItem(itemCard);
                    if(itemCard.isXType('form')) {
                        //console.info(itemCard.xtype);
                        if(itemCard.getForm().isDirty()) {
                            reset.enable();
                            if(itemCard.getForm().isValid()) {
                                save.enable();
                            }
                        } else {
                            reset.disable();
                            save.disable();
                        }
                    }
                    itemDetail.setTitle(rec.get('type') + ": " + rec.get('task'));
                    itemDetail.enable();*/
                    this.onLoadContact(form, model);
                    form.getEl().unmask();
                },
                failure: function(model, op) {
                    form.getEl().unmask();
                    Ext.MessageBox.show({
                       title: 'Error',
                       msg: 'The was a problem loading the record.</br>Error:' + PTS.app.getError(),
                       buttons: Ext.MessageBox.OK,
                       //animateTarget: 'mb9',
                       //fn: showResult,
                       icon: Ext.Msg.ERROR
                   });
                },
                scope: this
            });
        } else{
            form.loadRecord(Ext.create(model));
        }
    },

    /**
     * Load contact details.
     */
    loadRecordDetails: function(model, form) {
        var addRec, addSet, addCbx,
            phone = [
                {type:'fax',val:'1'},
                {type:'office',val:'3'},
                {type:'mobile',val:'2'}
            ],
            eaddress = [
                {type:'web',val:'2'},
                {type:'email',val:'1'}
            ];
        //load the contact details
        //TODO: implement "primary" filtering client-side
        //Allow management of additional addresses & phone#s
        if(model.addresses().count()) {//load addresses
            //mailing address
            if(addRec = model.addresses().findRecord( 'addresstypeid',1)) {
                addSet = form.down('fieldset#mailAddress');
                addCbx = addSet.down('checkbox[name=mailingCbx]');
                this.loadFieldSet(addRec, addSet, addCbx);
            }
            //physical address
            if(addRec = model.addresses().findRecord( 'addresstypeid',2)) {
                addSet = form.down('fieldset#physicalAddress');
                addCbx = addSet.down('checkbox[name=physicalCbx]');
                this.loadFieldSet(addRec, addSet, addCbx);
            }
        }

        if(model.phones().count()) {//load phones
            addCbx = form.down('checkbox[name=phoneCbx]');
            Ext.each(phone, function(itm){
                if(addRec = model.phones().findRecord( 'phonetypeid',itm.val)) {
                    addSet = form.down('fieldcontainer#' + itm.type + 'Phone');
                    this.loadFieldSet(addRec, addSet, addCbx);
                }
            },this);
        }

        if(model.eaddresses().count()) {//load electronic addresses
            Ext.each(eaddress, function(itm){
                if(addRec = model.eaddresses().findRecord( 'eaddresstypeid',itm.val)) {
                    addSet = form.down('fieldcontainer#' + itm.type + 'Address');
                    this.loadFieldSet(addRec, addSet);
                }
            },this);
        }
    }
});
