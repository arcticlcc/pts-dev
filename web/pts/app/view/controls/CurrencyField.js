/*
 * CurrencyField extends NumberField to format display as currency
 * http://www.sencha.com/forum/showthread.php?139600-CurrencyField-extends-NumberField-to-format-display-as-currency
 */
Ext.define('PTS.view.controls.CurrencyField', {
    extend: 'Ext.form.field.Number',
    alias: 'widget.currencyfield',

    hideTrigger: true,

    setValue: function (v) {
        this.callParent(arguments);

        if (!Ext.isEmpty(this.getValue())) {
            this.setRawValue(Ext.util.Format.currency(this.getValue()));
        }
    },

    removeFormat: function (v) {
        if (Ext.isEmpty(v)) {
            return '';
        } else {
            var thou = new RegExp(Ext.util.Format.thousandSeparator,'gi');
            v = v.toString().replace(Ext.util.Format.currencySign, '').replace(thou, '');
            if (v % 1 === 0) {
                // Return value formatted with no precision since there are no digits after the decimal
                return Ext.util.Format.number(v, '0');
            } else {
                // Return value formatted with precision of two digits since there are digits after the decimal
                return Ext.util.Format.number(v, '0.00');
            }
        }
    },

    // Override parseValue to remove the currency format
    parseValue: function (v) {
        return this.callParent([this.removeFormat(v)]);
    },

    // Remove the format before validating the value
    getErrors: function (v) {
        return this.callParent([this.removeFormat(v)]);
    },

    /* Override getSubmitData to remove the currency format on the value
    that will be passed out from the getValues method of the form */
    getSubmitData: function () {
        var returnObject = {};
        returnObject[this.name] = this.removeFormat(this.callParent(arguments)[this.name]);

        return returnObject;
    },

    // Override preFocus to remove the format during edit
    preFocus: function () {
        this.setRawValue(this.removeFormat(this.getRawValue()));

        this.callParent(arguments);
    }
});
