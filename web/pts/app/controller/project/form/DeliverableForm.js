/**
 * Controller for Deliverable Form
 */
Ext.define('PTS.controller.project.form.DeliverableForm', {
    extend: 'Ext.app.Controller',

    views: [
        'project.form.DeliverableForm'
    ],
    models: [
        'DeliverableType',
        'ModStatus'
    ],
    stores: [
        'DeliverableTypes',
        'DeliverableComments',
        'DeliverableStatuses',
        'DeliverableModStatuses',
        'DeliverableNotices',
        'NoticeRecipients',
        'Notices'
    ],
    refs: [{
        ref: 'deliverableForm',
        selector: 'deliverableform#itemCard-30 #itemForm'
    },{
        ref: 'deliverableCard',
        selector: 'deliverableform#itemCard-30'
    }],

    init: function() {
        this.control({
            'deliverableform#itemCard-30 #relatedDetails>roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            },
            'deliverableform#itemCard-30 #relatedDetails>#statusGrid': {
                validateedit: this.validateStatus
            },
            'deliverableform#itemCard-30 #mainCon combobox[name=deliverabletypeid]': {
                change: this.onChangeDelType
            }
        });

        // We listen for application-wide events
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            savedeliverable: this.onSave,
            scope: this
        });
    },

    /**
     * Disable the related details panel and clear any related grid stores.
     */
    onNewItem: function(model, form) {
        //we have to check the itemId
        if(this.getDeliverableCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid');

            form.ownerCt.down('#relatedDetails').disable();
            Ext.each(grids, function(gr){
                gr.getStore().removeAll();
            });
        }
    },

    /**
     * Check to see if this is a mod and set field write permissions.
     * Load the active roweditgrid, if any. Clear the other stores.
     * TODO: probably should use associations for this
     */
    onItemLoad: function(model, form) {
        var con,
            mod = !!model.get('parentdeliverableid');

        if(Ext.getClassName(model) === "PTS.model.Deliverable") {
            con = this.getDeliverableForm().down('#mainCon');

            con.items.each(function(itm) {
                itm.doNotEnable = mod ? true : false;
                //reset the opacity, set when edit button is clicked
                itm.getEl().setOpacity(1);
            });

        }

        //we have to check the itemId
        if(this.getDeliverableCard().itemId === form.ownerCt.itemId) {
            var grids = form.ownerCt.query('#relatedDetails>roweditgrid'),
                id = model.get('deliverableid');

            Ext.each(grids,function(gr){
                var store = gr.getStore(),
                    active = gr.tab === undefined ? gr.ownerCt.tab.active : gr.tab.active; //check the tab status

                if(active) {
                    this.updateDetailStore(store, id, gr.uri);
                    store.load({
                        callback: function(rec, op, success) {
                            if(success) {
                                gr.up('#relatedDetails').enable();
                            }
                        },
                        scope: gr
                    });
                }else {
                    store.removeAll();
                }
            }, this);
        }
    },

    /**
     * Update the record in the roweditgrid store with the deliverableid.
     */
    onDetailRowEdit: function(editor, e) {
        var model = this.getDeliverableForm().getRecord(),
            id = model.get('deliverableid'),
            mid = model.get('modificationid');

        editor.record.set('deliverableid',id);
        //set modificationid if it exists
        if(model.fields.containsKey('modificationid')) {
            editor.record.set('modificationid',mid);
        }
        editor.store.sync();

    },

    /**
     * Update the activated roweditgrid store with current the deliverableid.
     */
    onDetailActivate: function(grid) {
        var model = this.getDeliverableForm().getRecord(),
            store, id;

        if(model !== undefined) {
            store = grid.getStore();
            //only load if the store is not loading
            if(!store.isLoading() && store.count() === 0) {
                id = model.get('deliverableid');
                this.updateDetailStore(store, id, grid.uri);
                store.load();
            }
        }
    },

    /**
     * Change handler for deliverabletype combo.
     * Toggle visibility of period fieldcontainer.
     */
    onChangeDelType: function(field,newVal, oldVal) {
        var period = field.up('form').down('#delPeriod');

        //show period if type is financial or progress report
        period.setVisible(newVal === 6 || newVal === 13 || newVal === 25);
    },

    /**
     * Handler fired when the deliverable is saved.
     * Publishes deliverable to calendar.
     */
    onSave: function(model, operation) {
        var method = operation.request.method,
            data = model.data,
            url;

        switch (method) {
            case 'POST':
                url = '../deliverable/calendar/event';
                break;
            case 'PUT':
            case 'DELETE':
                url = '../deliverable/calendar/event/' + data.deliverableid;
                break;
        }

        Ext.Ajax.request({
            url: url,
            method: method,
            jsonData: Ext.encode(data),
            failure: function(response, opts) {
                Ext.create('widget.uxNotification', {
                    title: 'Error',
                    iconCls: 'ux-notification-icon-error',
                    html: 'Publishing to calendar failed </br>Error:' + PTS.app.getError()
                }).show();
            }
        });
    },

    /**
     * Update the roweditgrid store with the passed deliverableid.
     */
    updateDetailStore: function(store, id, uri) {

        //override store proxy based on deliverableid
        store.setProxy({
            type: 'rest',
            url : '../'+ uri,
            //appendId: true,
            api: {
                read:'../deliverable/' + id + '/' + uri
            },
            reader: {
                type: 'json',
                root: 'data'
            }
        });
    },

    /**
     * Validate the deliverable status.
     */
    validateStatus: function(editor, e) {
        var newStatus = e.newValues.deliverablestatusid,
            newDate = e.newValues.effectivedate.getTime(),
            oldDate = e.originalValues.effectivedate.getTime(),
            oldStatus = e.originalValues.deliverablestatusid;

        if(newStatus === oldStatus && newDate === oldDate) {
            return true;
        } else {
            var rec = e.record,
                modId = this.getDeliverableForm().getRecord().get('modificationid'),
                mask = new Ext.LoadMask(e.grid, {msg:"Validating. Please wait..."});

            mask.show();
            //query database for agreement status
            Ext.Ajax.request({
                url: '../modificationstatus',
                params: {
                    filter: '[{"property":"modificationid","value":'+ modId +'}]'
                },
                method: 'GET',
                success: function(response){
                    var resp = Ext.JSON.decode(response.responseText),
                        data = resp.data[0],
                        status = data === undefined ? 'Not Defined' : data.status,
                        msg = 'The agreement has has been marked <b>Completed</b>. ',
                        ctl = this,
                        //get the persisted records and filter for max date
                        delStatus = e.store.data.filter('phantom',false);
                        //get current deliverable status
                        delStatus.sort([
                            {
                                property: 'effectivedate',
                                direction:'DESC'
                            },{
                                property: 'deliverablestatusid',
                                direction: 'DESC'
                            }
                        ]);
                        delStatus = delStatus.first();

                    //test that modification status exists, is completed and that *current* del status is being set to < completed
                    if(resp.total > 0 && data.weight >= 90 && (delStatus && delStatus.getId() === rec.getId() &&
                        (newStatus < 40 || newDate < delStatus.get('effectivedate').getTime()))) {
                    //if records are found, raise error and cancel the update
                        e.column.getEditor().markInvalid(msg);
                        Ext.create('widget.uxNotification', {
                            title: 'Error',
                            iconCls: 'ux-notification-icon-error',
                            html: msg + 'Change the status of the agreement first.'
                        }).show();
                    } else {
                        //no errors, save the record
                        editor.getEditor().completeEdit();
                        ctl.onDetailRowEdit(e);
                        //check to see if agreement status is null or
                        // not completed and this is the only incomplete deliverable
                        if(newStatus >= 40 && (resp.total === 0 || (data.weight < 90 && data.incdeliverables <= 1))) {
                            msg = 'This agreement status is currently <i>' + status +
                                '</i>.<br/>Do you want to set the status to <b>Completed</b>?</br>' +
                                'You may also enter a comment (optional).</br></br>';
                            Ext.Msg.show({
                                 title:'Set Agreement Status?',
                                 msg: msg,
                                 buttons: Ext.Msg.YESNO,
                                 icon: Ext.Msg.QUESTION,
                                 prompt: true,
                                 fn: function(btn, text) {
                                    if(btn === 'yes') {
                                        var rec = ctl.getModStatusModel().create({
                                                modificationid: modId,
                                                statusid: 2,
                                                effectivedate: new Date(),
                                                comment: text
                                            }),
                                            wait = Ext.Msg.show({
                                                title: 'Saving...',
                                                msg: 'Saving status. Please wait...',
                                                wait: true,
                                                icon: Ext.window.MessageBox.INFO
                                            });

                                        rec.save({
                                            callback: function(record, op) {
                                                wait.close();
                                            }
                                        });
                                    }
                                 },
                                 scope: ctl
                            });
                        }
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
    }
});
