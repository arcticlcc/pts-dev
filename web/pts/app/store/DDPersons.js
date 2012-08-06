/**
 * Store of persons for filterable DD lists
 * Extends Persons store.
 */

Ext.define('PTS.store.DDPersons', {
    extend: 'PTS.store.Persons',

    remoteFilter: true

});
