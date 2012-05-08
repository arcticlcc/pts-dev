/**
 * Main Contact controller
 */
Ext.define('PTS.controller.contact.Contact', {
    extend: 'Ext.app.Controller',

    views: [
        /*'contact.tab.ContactTab',*/
        'contact.window.Window'
    ],

    controllers: [
        'contact.window.Window'
    ],

    init: function() {
        var tab = this.getController('contact.tab.ContactTab'),
        win = this.getController('contact.window.Window');

        // Remember to call the init method manually
        tab.init();
        win.init();

    },

    /**
     * Creates and opens the contact window.
     * @param {Ext.Component/Number/String} type The card, itemId, or index to load.
     *
     * - **0** : **Default** Person form
     * - **1** : Group form
     * @param {Object} [record] An optional contact record.
     */
    openContact: function(type,record) {
        var win, code,
            id = record ? record.getId() : false;

        type = type ? type : 0;

        if(id !== false) {
            code = record.getContactName();

            win = Ext.create(this.getContactWindowWindowView(),{
                title: 'Edit Contact: ' + code
            });
        } else{
            win = Ext.create(this.getContactWindowWindowView(),{
                title: 'New Contact'
            });
        }

        //win.down('contactform').getLayout().setActiveItem(type);

        this.application.fireEvent('opencontact', id, type);

        win.show();
    }

    //TODO: closeContact event: clear dependant stores
});
