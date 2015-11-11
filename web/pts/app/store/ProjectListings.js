/**
 * File: app/store/ProjectListings.js
 * Description: Store of project listings for displaying lists of projects
 * with computed attibutes.
 */

Ext.define('PTS.store.ProjectListings', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectListing',

    remoteSort: true,
    remoteFilter: true,
    pageSize: PTS.Defaults.pageSize,
    sorters: [{
        property: 'fiscalyear',
        direction: 'DESC'
    }, {
        property: 'number',
        direction: 'DESC'
    }]
});
