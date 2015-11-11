/**
 * The ContactDetail controller
 */
Ext.define('PTS.controller.contact.window.ContactDetail', {
    extend: 'Ext.app.Controller',

    views: [
        'contact.window.ContactDetail'
    ],
    models: [
        'Address',
        'EAddress',
        'Phone'
    ],
    stores: [
        'States'
    ],
    refs: [{
        ref: 'contactForm',
        selector: 'contactform'
    }],

    init: function() {

        this.control({
            'contactform contactdetail #sameAddCbx': {
                change: this.copyMailAddress
            },
            'contactform contactdetail countrycombo': {
                select: this.countryChange
            },
            'contactform addressfieldset #postalcode': {
                blur: this.onPostalBlur,
                validitychange: this.onPostalValidate
            },
            'contactform addressfieldset statecombo': {
                expand: this.onStateExpand
            }

        });

        // We listen for the application-wide loadcontact event
        this.application.on({
            loadcontact: this.onLoadContact,
            scope: this
        });
    },

    /**
     * Copy the mailing address to the current form's physical address.
     *
     */
    copyMailAddress: function(cbx) {
        var phys = cbx.up('fieldset'),
            mail = cbx.up('contactdetail').down('#mailAddress');

        if (cbx.getValue()) {
            //copy vals from mailing fieldset
            Ext.each(mail.query('field'), function(itm) {
                var val = itm.getValue(),
                    name = itm.getName(),
                    copy = phys.down('field[name=' + name + ']');

                if ('addressid' !== name && copy) {
                    //data[name] = val;
                    copy.setValue(val);
                    copy.disable();
                }
            });
        } else {
            //enable fields
            Ext.each(phys.query('field'), function(itm) {
                itm.enable();
            });
        }
    },

    /**
     * Filter the state store when the country is changed.
     *
     */
    countryChange: function(cmb) {
        var stateStore = this.getStatesStore(),
            country = cmb.getValue();

        stateStore.clearFilter();
        this.filterState(country);
    },

    /**
     * Actions to take when the postalcode field blurs.
     * TODO: Only works right now for US/CA.
     * TODO: Need to actually check to see if value has changed since last lookup instead of using isDirty.
     */
    onPostalBlur: function(fld) {
        var val = fld.getValue(),
            fldset = fld.up('addressfieldset'),
            country = fldset.down('#country').getValue();

        //look up the state and city
        if (fld.isDirty() && !Ext.isEmpty(fld.getValue())) {
            Ext.Ajax.request({
                url: '../country/' + country + '/postalcode/' + val,
                success: function(response) {
                    var state = fldset.down('#state'),
                        city = fldset.down('#city'),
                        data = Ext.decode(response.responseText).data;

                    state.setValue(data.stateid);
                    state.enable();
                    city.setValue(data.placename);
                    city.enable();
                },
                failure: function(response) {
                    var msg = Ext.decode(response.responseText).message;

                    fld.markInvalid(msg);
                }
            });
        }
    },

    /**
     * Actions to take when the postalcode field is validated.
     */
    onPostalValidate: function(fld, isValid) {
        var fldset = fld.up('addressfieldset');

        fldset.down('#state').setDisabled(!isValid);
        fldset.down('#city').setDisabled(!isValid);
    },

    /**
     * Check for null values in city and state for each addressfieldset
     * @param
     */
    onLoadContact: function(form, model) {
        var fields = form.query('#postalcode');

        Ext.each(fields, function(fld) {
            var cs = fld.up('addressfieldset').query('#city, #state'),
                empty = Ext.isEmpty(fld.getValue());

            Ext.each(cs, function() {
                this.setDisabled(empty);
            });

        });
    },

    /**
     * When the statecombo is expanded filter the statecombo store by country
     */
    onStateExpand: function(picker) {
        var val = picker.up('addressfieldset').down('countrycombo').getValue(),
            filter = this.getStatesStore().filters.get('country');

        //don't refilter with same value
        if (val && !(filter && (val === filter.value))) {
            this.filterState(val);
        }

    },

    /**
     * Filter the statecombo store by country
     */
    filterState: function(val) {
        this.getStatesStore().filter({
            id: 'country',
            property: 'countryalpha',
            value: val
        });
    }
});
