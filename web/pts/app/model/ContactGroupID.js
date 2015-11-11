/**
 * Description: ContactGroupID model.
 */

Ext.define('PTS.model.ContactGroupID', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'contactid',
        mapping: 'contactid',
        type: 'int',
        persist: false
    }, {
        name: 'fullname',
        type: 'mystring',
        useNull: true,
        persist: false
    }],
    idProperty: 'contactid'
});
