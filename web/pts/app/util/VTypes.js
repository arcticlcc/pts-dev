/**
 * Custom Vtypes
 *
 * All of the methods document here are applied to Ext.form.field.VTypes
 */
Ext.define('PTS.util.VTypes', {
    singleton: true,
    requires: [
        'Ext.form.field.VTypes'
    ]
}, function() {
    Ext.apply(Ext.form.field.VTypes, {
        /**
         * @method daterange
         * Custom date range validation
         */
        daterange: function(val, field) {
            var date = field.parseDate(val);

            if (field.startDateField &&
                (!field.dateRangeMax || date === null || (date.getTime() !== field.dateRangeMax.getTime()) )) {
                //check ownerCt first, otherwise check for form
                var start = field.ownerCt.down('datefield[vfield=beginDate]') || field.up('form').down('datefield[vfield=beginDate]');
                start.setMaxValue(date);
                start.validate();
                field.dateRangeMax = date;
            }
            else if (field.endDateField &&
                (!field.dateRangeMin  || date === null || (date.getTime() !== field.dateRangeMin.getTime()) )) {
                var end = field.ownerCt.down('datefield[vfield=endDate]') || field.up('form').down('datefield[vfield=endDate]');
                end.setMinValue(date);
                end.validate();
                field.dateRangeMin = date;
            }
            /*
             * Always return true since we're only using this vtype to set the
             * min/max allowed values (these are tested for after the vtype test)
             */
            return true;
        },
        daterangeText: 'From date must be before To date',
        /**
         * @method moddaterange
         * Custom date range validation for modifications only
         * Use ids to find start/end datefields
         */
        moddaterange: function(val, field) {
            var date = field.parseDate(val),
                fields = [
                        field.up('form').down('#startDate'),
                        field.up('form').down('#effectiveDate')
                    ];

            //enddate
            if (field.startDateField &&
                (!field.dateRangeMax || date === null || (date.getTime() !== field.dateRangeMax.getTime()) )) {
                fields.push(field.up('form').down('#' + field.startDateField));

                Ext.each(fields, function(itm){
                    itm.setMaxValue(date);
                    itm.validate();
                });
                field.dateRangeMax = date;
            }
            //datecreated
            else if (field.endDateField &&
                (!field.dateRangeMin  || date === null || (date.getTime() !== field.dateRangeMin.getTime()) )) {
                fields.push(field.up('form').down('#' + field.endDateField));

                Ext.each(fields, function(itm){
                    itm.setMinValue(date);
                    itm.validate();
                });
                field.dateRangeMin = date;
            }
            /*
             * Always return true since we're only using this vtype to set the
             * min/max allowed values (these are tested for after the vtype test)
             */
            return true;
        },
        moddaterangeText: 'From date must be before To date'
    });
    }
);
