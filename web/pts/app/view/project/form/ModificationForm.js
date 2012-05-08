/**
 * File: app/view/project/form/ModificationForm.js
 * Form for editing Modification information.
 */

Ext.define('PTS.view.project.form.ModificationForm', {
    extend: 'PTS.view.project.form.AgreementForm',
    alias: 'widget.modificationform',

    itemId: 'itemCard-60',
    title: 'Modification',

    initComponent: function() {
        var me = this;
        me.callParent(arguments);

        //TODO: probably move this to controller??
        this.down('#itemForm').getForm().findField('modtypeid').disable(true);
    }
});
