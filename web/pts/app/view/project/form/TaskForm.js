/**
 * File: app/view/project/form/TaskForm.js
 * Form for editing Task information.
 */

Ext.define('PTS.view.project.form.TaskForm', {
    extend: 'PTS.view.project.form.DeliverableForm',
    alias: 'widget.taskform',
    requires: [
        'Ext.form.RadioGroup'
    ],

    itemId: 'itemCard-40',
    title: 'Task',

    initComponent: function() {
        var me = this;
        me.callParent(arguments);
    }
});
