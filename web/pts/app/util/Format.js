/**
 * PTS data formatting utility functions.
 */
Ext.define('PTS.util.Format', {
    singleton: true,

    /**
     * Formats values as US currency
     * @param {Number} value The value to format
     */
    netFunds: function (val) {
        var vf = Ext.util.Format.usMoney(val);
        if (val > 0) {
            return '<span style="color:green;">' + vf + '</span>';
        } else if (val < 0) {
            return '<span style="color:red;">' + vf + '</span>';
        }
        return val;
    },

    /**
     * Formats project code
     * @param {Number/String} fiscalyear The fiscal year of the project
     * @param {Number/String} number The project number
     */
    projectCode: function (fy,num) {
        var s = (num < 10) ? '-0': '-';
        return fy + s + num;
    }
});
