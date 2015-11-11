/**
 * Govunit State model.
 */

Ext.define('PTS.model.State', {
    extend: 'PTS.model.Base',
    fields: [{
        name: 'stateid',
        type: 'int'
    }, {
        name: 'unittype',
        type: 'mystring',
        useNull: true
    }, {
        name: 'statenumeric',
        type: 'mystring',
        useNull: true
    }, {
        name: 'statealpha',
        type: 'mystring',
        useNull: true
    }, {
        name: 'statename',
        type: 'mystring',
        useNull: true
    }, {
        name: 'countryalpha',
        type: 'mystring',
        useNull: true
    }, {
        name: 'countryname',
        type: 'mystring',
        useNull: true
    }, {
        name: 'featurename',
        type: 'mystring',
        useNull: true
    }],
    idProperty: 'stateid',

    proxy: {
        type: 'rest',
        url: '../statelist',
        reader: {
            type: 'json',
            root: 'data'
        },
        limitParam: undefined
    }
});
