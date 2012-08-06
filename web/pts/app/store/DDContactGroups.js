/**
 * Store of ContactGroups for filterable DD lists
 * Extends ContactGroups store.
 */

Ext.define('PTS.store.DDContactGroups', {
    extend: 'PTS.store.ContactGroups',

    remoteFilter: true

});
