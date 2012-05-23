/**
 * File: app/store/ProjectFunders.js
 * Description: Store of project contacts
 * with computed attibutes.
 */

Ext.define('PTS.store.ProjectFunders', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectContact',

    autoLoad: false
});
