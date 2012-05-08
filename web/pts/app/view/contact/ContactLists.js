/**
 * File: app/view/contact/ContactLists.js
 *
 * Contact Lists tab panel with draggable contacts.
 */
Ext.define('PTS.view.contact.ContactLists', {
    extend: 'Ext.tab.Panel',
    alias: 'widget.contactlists',
    requires: [
        'PTS.view.contact.GroupDDList',
        'PTS.view.contact.PersonDDList'
    ],
    itemId: 'contactLists',
    activeTab: 0,
    plain: true,
    flex: 1,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'personddlist',
                    itemId: 'personsList',
                    title: 'Persons'
                },
                {
                    xtype: 'groupddlist',
                    itemId: 'groupsList',
                    title: 'Groups'
                }
            ],
            dockedItems: [
                {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'button',
                            //itemId: 'addtoproject',
                            iconCls: 'pts-menu-addbasic',
                            text: 'Add to Project',
                            action: 'addcontacts'
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }
});
