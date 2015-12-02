/**
 * File: app/model/FundingType.js
 * Description: FundingType model.
 */

Ext.define('PTS.model.FundingType', {
    extend: 'PTS.model.Base',
    fields: [{
            name: 'fundingtypeid',
            type: 'int',
            persist: false
        }, {
            name: 'code',
            type: 'mystring',
            useNull: true
        }, {
            name: 'type',
            type: 'mystring',
            useNull: true
        }, {
            name: 'description',
            type: 'mystring',
            useNull: true
        }

    ],
    idProperty: 'fundingtypeid',

    proxy: {
        type: 'rest',
        url: PTS.baseURL + '/fundingtype',
        reader: {
            type: 'json',
            root: 'data'
        }
    }
});
