/**
 * Description: ContactGroupID model.
 */

Ext.define('PTS.model.ContactGroupID', {
    extend: 'Ext.data.Model',
    fields: [
        {
            name: 'contactid',
            mapping: 'contactid',
            type: 'int',
            persist: false
        },
        {
            name: 'fullname', type: 'mystring', useNull: true, persist: false
        }
    ],
    idProperty: 'contactid'
});
