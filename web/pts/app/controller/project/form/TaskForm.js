/**
 * Controller for Task Form
 */
Ext.define('PTS.controller.project.form.TaskForm', {
    extend: 'Ext.app.Controller',

    views: [
        'project.form.TaskForm'
    ],
    models: [
        'DeliverableType'
    ],
    stores: [
        'DeliverableTypes'
    ],
    refs: [{
        ref: 'taskForm',
        selector: 'taskform'
    }],

    init: function() {
        this.control({
            'taskform #itemForm': {
                beforerender: this.onBeforeRender
            }
        });

        // We listen for the application-wide openproject event
        /*this.application.on({
            openproject: this.onOpenProject,
            scope: this
        });*/
    },

    onBeforeRender: function(form) {
        var data = [], myGroup, cbx, idx, cont;

        //create radio items
        this.getDeliverableTypesStore().each(function(rec) {
            var txt = 'task'.toLowerCase(),
                itm = rec.get('type');

            if((itm.indexOf(txt)+1)) {
                data.push({
                    boxLabel: itm,
                    name: 'deliverabletypeid',
                    inputValue: rec.get('deliverabletypeid')
                });
            }
        });
        //create radiogroup
        myGroup = {
            xtype: 'radiogroup',
            fieldLabel: 'Type',
            items: data,
            width: 300,
            listeners: {
                change: function(cbx,newVal,oldVal){
                //fix to make sure the form fires dirtychange events,
                //not firing in 4.0.7 on initial change
                    cbx.up('#itemForm').getForm().checkDirty();
                }
            }
        };
        //replace type combo with radiogroup
        cont =  form.down('#mainCon');
        cbx = cont.down('combobox[name=deliverabletypeid]');
        idx = cont.items.indexOf(cbx);
        cont.remove(cbx);
        cont.insert(idx,myGroup);

    }
});
