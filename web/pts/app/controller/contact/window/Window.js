/**
 * Project Window controller.
 */
Ext.define('PTS.controller.contact.window.Window', {
    extend: 'Ext.app.Controller',

    views: [
        'contact.window.Window'
        /*,
                'contact.window.ContactForm'*/
    ],

    refs: [{
            ref: 'contactWindow',
            selector: 'contactwindow'
        }
        /*,{
                ref: 'contactForm',
                selector: 'contactform'
            }*/
    ],

    init: function() {

        var cf = this.getController('contact.window.ContactForm');

        // Remember to call the init method manually
        cf.init();

        this.control({
            'contactwindow [action=closewindow]': {
                click: this.closeWindow
            }
            /*,
                        'contacttab button[action=editcontact]': {
                            click: this.editContact
                        },
                        'contactwindow tool[type=save]' : {
                            click: this.closeWindow
                        }*/
        });
    },

    /**
     * Closes the contact window.
     */
    closeWindow: function() {
        this.getContactWindow().close();
    }
});
