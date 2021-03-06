/**
 * File: app/model/Funding.js
 * Description: Funding model.
 */

Ext.define('PTS.model.Funding', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'fundingid',
        type: 'int',
        persist: false
    }, {
        name: 'modificationid',
        type: 'int',
        persist: true,
        useNull: true
    }, {
        name: 'fundingtypeid',
        type: 'int',
        useNull: true
    }, {
        name: 'projectcontactid',
        type: 'int',
        useNull: true
    }, {
        name: 'fundingrecipientid',
        type: 'int',
        useNull: true
    }, {
        name: 'amount',
        type: 'number',
        useNull: true
    }, {
        name: 'title',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'fundingid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/funding',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
