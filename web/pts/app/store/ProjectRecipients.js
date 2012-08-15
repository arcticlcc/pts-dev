/**
 * Description: Store of project funding recipients
 */

Ext.define('PTS.store.ProjectRecipients', {
    extend: 'Ext.data.Store',
    model: 'PTS.model.ProjectContact',

    autoLoad: false,
    sorters: [
        'name'
    ]
});
