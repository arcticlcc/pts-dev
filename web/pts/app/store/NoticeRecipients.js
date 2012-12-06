/**
 * Store of project notice recipients with computed attributes.
 */

Ext.define('PTS.store.NoticeRecipients', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectContact',

    autoLoad: false,
    sorters: [
        'name'
    ]
});
