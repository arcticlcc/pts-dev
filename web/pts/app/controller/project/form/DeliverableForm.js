/**
 * Controller for Deliverable Form
 */
Ext.define('PTS.controller.project.form.DeliverableForm', {
    extend: 'Ext.app.Controller',

    views: [
        'project.form.DeliverableForm'
    ],
    models: [
        'DeliverableType'
    ],
    stores: [
        'DeliverableTypes'
    ],
    refs: [{
        ref: 'deliverableForm',
        selector: 'deliverableform #itemForm'
    }],

    init: function() {
        /*this.control({
            'fundingform': {
                beforeactivate: this.onBeforeActivate
            }
        });*/

        // We listen for the application-wide loaditem event
        this.application.on({
            itemload: this.onItemLoad,
            scope: this
        });
    },

    /**
     * Check to see if this is a mod and set field write permissions.
     */
    onItemLoad: function(model) {
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
    }
});
