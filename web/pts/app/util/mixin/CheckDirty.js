/**
 *@class PTS.util.mixin.CheckDirty
 *A mixin that checks a container's items for dirty fields
 */
Ext.define('PTS.util.mixin.CheckDirty', {
    requires: ['Ext.Array'],

    /**
     * Check the container for dirty fields
     * @return {Boolean}
     */
    isDirty: function() {
        var fields = this.query('field');
        return !Ext.Array.every(fields, function(f) {
            return !f.isDirty();
        });
    },

    /**
     * Check the container validity
     * @return {Boolean}
     */
    isValid: function() {
        var fields = this.query('field');
        return Ext.Array.every(fields, function(f) {
            return f.isValid();
        });
    }
});
