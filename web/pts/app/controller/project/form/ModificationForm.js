/**
 * Controller for Modification Form
 */
Ext.define('PTS.controller.project.form.ModificationForm', {
    extend: 'PTS.controller.project.form.BaseModificationForm',

    views: [
        'project.form.AgreementForm',
        'project.form.ModificationForm'
    ],
    models: [
        'PurchaseRequest',
        'Status',
        'ModStatus'
    ],
    stores: [
        'PurchaseRequests',
        'Statuses',
        'ModStatuses'
    ],
    refs: [{
        ref: 'agreementForm',
        selector: 'modificationform#itemCard-60 #itemForm'
    }, {
        ref: 'agreementCard',
        selector: 'modificationform#itemCard-60'
    }],

    init: function() {
        this.control({
            'modificationform#itemCard-60 roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            },
            'agreementform#itemCard-60 #statusGrid': {
                validateedit: this.validateStatus
            },
            'agreementform#itemCard-60 textfield[name=modcode]': {
                change: this.onChangeCode
            }
        });

        // We listen for the application-wide loaditem event
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            savemodification: this.onSaveModification,
            scope: this
        });

    },

    /**
     * Set the create and save a status(Created).
     */
    onSaveModification: function(model, op, phantom) {
        //only needed for modifications
        if (phantom) {
            var store = this.getModStatusesStore(),
                rec = this.getModStatusModel().create({
                    statusid: 10,
                    comment: 'This status was automatically created.',
                    effectivedate: new Date(),
                    modificationid: model.get('modificationid')
                });

            store.add(rec);
            store.sync();
        }
    },

    /**
     * Set the parent code in the form and record.
     */
    onNewItem: function(model, form) {
        //only needed for modifications
        if (this.getAgreementCard().itemId === form.ownerCt.itemId) {
            var code = form.up('#projecttabpanel').down('agreementstree').getSelectionModel().selected.first().get('parentcode'),
                bform = form.getForm();

            model.set('parentcode', code);
            bform.findField('parentcode').setValue(code);
            //reset the modcode
            bform.findField('modcode').setValue('').resetOriginalValue();
        }
        this.callParent(arguments);
    },

    /**
     * Set the parent code in the form and record.
     */
    onItemLoad: function(model, form) {
        //only needed for modifications
        if (this.getAgreementCard().itemId === form.ownerCt.itemId) {
            var bform = form.getForm(),
                modcode = bform.findField('modcode'),
                del = bform.findField('codedelimiter').getValue(),
                val = model.get('modificationcode').split(del),
                parentcode = String(model.get('parentcode')),
                code, msg;

            //set the code
            if (val.length > 1) {
                code = val.slice(1).join(del);
            } else {
                code = val[0];
            }

            //don't print null, use an empty string
            if (code === null || code == 'null') {
                code = '';
            }

            //modcode.originalValue = code;
            modcode.setValue(code).resetOriginalValue();

            //check parentcode against model
            if (model.get('modificationcode') && val[0] !== parentcode) {
                msg = 'The parent code for this modification has changed.' +
                    '<br/>Do you want to update the code for this modification now?</br>';

                Ext.Msg.show({
                    title: 'Update Code?',
                    msg: msg,
                    buttons: Ext.Msg.YESNO,
                    icon: Ext.Msg.QUESTION,
                    fn: function(btn, text) {
                        if (btn === 'yes') {
                            var wait = Ext.Msg.show({
                                title: 'Saving...',
                                msg: 'Saving Mod. Please wait...',
                                wait: true,
                                icon: Ext.window.MessageBox.INFO
                            });
                            bform.findField('modificationcode').setRawValue(parentcode + del + code);
                            bform.updateRecord(model);
                            model.save({
                                callback: function(record, op) {
                                    wait.close();
                                }
                            });
                        }
                    },
                    scope: this
                });
            }
        }
        this.callParent(arguments);
    },

    /**
     * Update the modificationcode.
     */
    onChangeCode: function(field) {
        var form = field.up('form').getForm(),
            rec = form.getRecord(),
            val = form.findField('modcode').getValue(),
            del = form.findField('codedelimiter').getValue(),
            code = rec.get('parentcode') + del + val;

        form.findField('modificationcode').setRawValue(code);
    }
});
