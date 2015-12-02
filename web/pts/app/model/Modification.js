/**
 * File: app/model/Modification.js
 * Description: Modification model.
 */

Ext.define('PTS.model.Modification', {
    extend: 'PTS.model.Base',
    //requires: ['PTS.util.DataTypes'],
    fields: [{
        name: 'modificationid',
        type: 'int',
        persist: false
    }, {
        name: 'projectid',
        type: 'int',
        useNull: true
    }, {
        name: 'modtypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'personid',
        type: 'int',
        useNull: true
    }, {
        name: 'parentmodificationid',
        type: 'int',
        useNull: true
    }, {
        name: 'parentcode',
        type: 'mystring',
        persist: false
    }, {
        name: 'startdate',
        type: 'mydate'
    }, {
        name: 'enddate',
        type: 'mydate'
    }, {
        name: 'effectivedate',
        type: 'mydate'
    }, {
        name: 'datecreated',
        type: 'mydate',
        persist: false
    }, {
        name: 'modificationcode',
        type: 'mystring',
        useNull: true
    }, {
        name: 'title',
        type: 'mystring',
        useNull: true
    }, {
        name: 'shorttitle',
        type: 'mystring',
        useNull: true
    }, {
        name: 'description',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'modificationid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/modification',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
