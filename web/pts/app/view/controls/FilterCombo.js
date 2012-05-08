/**
 * Combo box that accounts for applied filters when performing *local* querystring filtering.
 * Extends PTS.view.controls.MyCombo any filters on it's store when destroyed.
 */
Ext.define('PTS.view.controls.FilterCombo', {
    extend: 'PTS.view.controls.MyCombo',
    alias: 'widget.filtercombo',
    requires: ['Ext.form.field.ComboBox'],

    /**
     * @cfg {Array}
     * The base filter to apply to the combobox store.
     * This filter is always reapplied after the combobox querystring filter is cleared.
     */
    baseFilter: null,

    /**
     * Overrides the default method to allow filtering the combobox store
     */
    doQuery: function (queryString, forceAll, rawQuery) {
        queryString = queryString || '';

        // store in object and pass by reference in 'beforequery'
        // so that client code can modify values.
        var me = this,
            qe = {
                query: queryString,
                forceAll: forceAll,
                combo: me,
                cancel: false
            },
            store = me.store,
            isLocalMode = me.queryMode === 'local';
            //country = me.up('addressfieldset').down('countrycombo').getValue();

        if (me.fireEvent('beforequery', qe) === false || qe.cancel) {
            return false;
        }

        // get back out possibly modified values
        queryString = qe.query;
        forceAll = qe.forceAll;

        // query permitted to run
        if (forceAll || (queryString.length >= me.minChars)) {
            // expand before starting query so LoadMask can position itself correctly
            me.expand();

            // make sure they aren't querying the same thing
            if (!me.queryCaching || me.lastQuery !== queryString) {
                me.lastQuery = queryString;

                if (isLocalMode) {
                    // forceAll means no filtering - show whole dataset.
                    if (forceAll) {
                        store.clearFilter();
                    } else {
                        // Clear filter, but supress event so that the BoundList is not immediately updated.
                        store.clearFilter(true);
                        store.filter(me.displayField, queryString);
                    }
                    if(this.baseFilter) {
                        // Apply the base filter in addition to the
                        // currently active query text filter:
                        store.filter(this.baseFilter);
                    }
                } else {
                    // Set flag for onLoad handling to know how the Store was loaded
                    me.rawQuery = rawQuery;

                    // In queryMode: 'remote', we assume Store filters are added by the developer as remote filters,
                    // and these are automatically passed as params with every load call, so we do *not* call clearFilter.
                    if (me.pageSize) {
                        // if we're paging, we've changed the query so start at page 1.
                        me.loadPage(1);
                    } else {
                        store.load({
                            params: me.getParams(queryString)
                        });
                    }
                }
            }

            // Clear current selection if it does not match the current value in the field
            if (me.getRawValue() !== me.getDisplayValue()) {
                me.ignoreSelection++;
                me.picker.getSelectionModel().deselectAll();
                me.ignoreSelection--;
            }

            if (isLocalMode) {
                me.doAutoSelect();
            }
            if (me.typeAhead) {
                me.doTypeAhead();
            }
        }
        return true;
    },

    initComponent: function() {
        var me = this;
        me.callParent(arguments);
    }
});
