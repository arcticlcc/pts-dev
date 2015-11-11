/**
 * Controller for Task Form
 */
Ext.define('PTS.controller.project.form.TaskForm', {
    extend: 'PTS.controller.project.form.DeliverableForm',

    views: [
        'project.form.TaskForm'
    ],
    models: [
        'DeliverableType'
    ],
    stores: [
        'DeliverableTypes',
        'DeliverableComments',
        'TaskStatuses'
    ],
    refs: [{
        ref: 'deliverableForm',
        selector: 'deliverableform#itemCard-40 #itemForm'
    }, {
        ref: 'deliverableCard',
        selector: 'deliverableform#itemCard-40'
    }],

    init: function() {
        this.control({
            'taskform #itemForm': {
                beforerender: this.onBeforeRender
            },
            'taskform#itemCard-40 #relatedDetails>roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            }
        });

        // We listen for application-wide events
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });
    },

    onBeforeRender: function(form) {
        var data = [],
            myGroup, cbx, idx, cont;

        //create radio items
        Ext.getStore('TaskTypes').each(function(rec) {
            data.push({
                boxLabel: rec.get('type'),
                name: 'deliverabletypeid',
                inputValue: rec.get('deliverabletypeid')
            });
        });
        //create radiogroup
        myGroup = {
            xtype: 'radiogroup',
            fieldLabel: 'Type',
            items: data,
            width: 300,
            listeners: {
                change: function(cbx, newVal, oldVal) {
                    //fix to make sure the form fires dirtychange events,
                    //not firing in 4.0.7 on initial change
                    cbx.up('#itemForm').getForm().checkDirty();
                }
            }
        };
        //replace type combo with radiogroup
        cont = form.down('#mainCon');
        cbx = cont.down('combobox[name=deliverabletypeid]');
        idx = cont.items.indexOf(cbx);
        cont.remove(cbx);
        cont.insert(idx, myGroup);
        //hide period fields
        form.down('#delPeriod').hide();
    }
});
