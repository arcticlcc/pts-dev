/**
 * Various Overrides for ExtJS.
 */
Ext.define('PTS.Overrides', {
    singleton: true,
    requires: [
        'Ext.form.field.Radio',
        'Ext.data.AbstractStore',
        'Ext.data.proxy.Proxy',
        'Ext.view.AbstractView',
        'Ext.form.field.ComboBox',
        'Extensible.calendar.view.Month',
        'Ext.grid.RowEditor',
        'Ext.Array',
        'Ext.util.Sorter'

    ]
}, function() {
    //RowEditor ignores errorSummary
    //http://www.sencha.com/forum/showthread.php?132214
    //Fixed in 4.1
    Ext.override(Ext.grid.RowEditor, {
        loadRecord: function(record) {
            var me = this,
            form = me.getForm();
            form.loadRecord(record);

            if(form.isValid()) {
                me.hideToolTip();
            } else if(me.errorSummary) {
                me.showToolTip();
            }

            Ext.Array.forEach(me.query('>displayfield'), function(field) {
                me.renderColumnData(field, record);
            }, me);
        }
    });

    //Override the default sorter
    //PostgreSQL treats nulls as "larger" than non-nulls by default
    //ExtJS will not handle nulls in strings correctly
    Ext.override(Ext.util.Sorter, {
        defaultSorterFn: function(o1, o2) {
            var me = this,
                transform = me.transform,
                v1 = me.getRoot(o1)[me.property],
                v2 = me.getRoot(o2)[me.property];

            if (transform) {
                v1 = transform(v1);
                v2 = transform(v2);
            }

            if(null !== v1 && null !== v2) { //neither value is null
                return v1 > v2 ? 1 : (v1 < v2 ? -1 : 0);

            }else if(v1 === v2) { //both values are null
                return 0;

            }else { //one value is null
                return v1 === null ? 1 : -1;

            }
        }
    });
    //fix loadmask issue, still happens with masked views that are visible behind modal
    //http://www.sencha.com/forum/showthread.php?150040-Unexplained-load-mask-in-upper-left-corner-of-browser-again/page4
    Ext.override(Ext.view.AbstractView, {
        onMaskBeforeShow: function() {
            if(!this.el.isVisible(true)) {
                return false;
            }
            this.callOverridden(arguments);
        }
    });
    //http://www.sencha.com/forum/showthread.php?182524-RadioField-and-isDirty-problem&p=745308&viewfull=1#post745308
    //http://stackoverflow.com/questions/6490845/extjs-4-issue-with-a-radiogroup-which-is-always-dirty
    Ext.override(Ext.form.field.Radio, {
        resetOriginalValue: function () {
            //Override the original method in Ext.form.field.Field:
            //this.originalValue = this.getValue();
            //this.checkDirty();
            this.getManager().getByName(this.name).each(function (item) {
                item.originalValue = item.getValue();
                item.checkDirty();
            });
        }
    });
    //TODO: Taken from 4.1
    //http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing/page2
    //Adds callbacks to sync method
    Ext.override(Ext.data.AbstractStore, {
        sync: function(options) {
            var me = this,
                operations = {},
                toCreate = me.getNewRecords(),
                toUpdate = me.getUpdatedRecords(),
                toDestroy = me.getRemovedRecords(),
                needsSync = false;

            if (toCreate.length > 0) {
                operations.create = toCreate;
                needsSync = true;
            }

            if (toUpdate.length > 0) {
                operations.update = toUpdate;
                needsSync = true;
            }

            if (toDestroy.length > 0) {
                operations.destroy = toDestroy;
                needsSync = true;
            }

            if (needsSync && me.fireEvent('beforesync', operations) !== false) {
                options = options || {};

                me.proxy.batch(Ext.apply(options, {
                    operations: operations,
                    listeners: me.getBatchListeners()
                }));
            }

            return me;
        }
    });
    Ext.override(Ext.data.proxy.Proxy, {
        batch: function(options, /* deprecated */listeners) {
            var me = this,
                useBatch = me.batchActions,
                batch,
                records;

            if (options.operations === undefined) {
                // the old-style (operations, listeners) signature was called
                // so convert to the single options argument syntax
                options = {
                    operations: options,
                    listeners: listeners
                };
            }

            if (options.batch) {
                if (Ext.isDefined(options.batch.runOperation)) {
                    batch = Ext.applyIf(options.batch, {
                        proxy: me,
                        listeners: {}
                    });
                }
            } else {
                options.batch = {
                    proxy: me,
                    listeners: options.listeners || {}
                };
            }

            if (!batch) {
                batch = new Ext.data.Batch(options.batch);
            }

            batch.on('complete', Ext.bind(me.onBatchComplete, me, [options], 0));

            Ext.each(me.batchOrder.split(','), function(action) {
                records = options.operations[action];
                if (records) {
                    if (useBatch) {
                        batch.add(new Ext.data.Operation({
                            action: action,
                            records: records
                        }));
                    } else {
                        Ext.each(records, function(record) {
                            batch.add(new Ext.data.Operation({
                                action : action,
                                records: [record]
                            }));
                        });
                    }
                }
            }, me);

            batch.start();
            return batch;
        },

        /**
         * @private
         * The internal callback that the proxy uses to call any specified user callbacks after completion of a batch
         */
        onBatchComplete: function(batchOptions, batch) {
            var scope = batchOptions.scope || this;

            if (batch.hasException) {
                if (Ext.isFunction(batchOptions.failure)) {
                    Ext.callback(batchOptions.failure, scope, [batch, batchOptions]);
                }
            } else if (Ext.isFunction(batchOptions.success)) {
                Ext.callback(batchOptions.success, scope, [batch, batchOptions]);
            }

            if (Ext.isFunction(batchOptions.callback)) {
                Ext.callback(batchOptions.callback, scope, [batch, batchOptions]);
            }
        }
    });
    //Add tooltips to Extensible Calendars
    //http://ext.ensible.com/forum/viewtopic.php?f=4&t=191&p=1488&hilit=tooltip#p1488
    Extensible.calendar.view.Month.override({
       getEventTemplate : function(){
          if(!this.eventTpl){
             var tpl, body = this.getEventBodyMarkup();

             tpl = !(Ext.isIE || Ext.isOpera) ?
                Ext.create('Ext.XTemplate',
                   '<div data-qtip="<b>{Title}</b><br/>Project: {ProjectCode}<br/>Type: {Type}<br/>Manager: {Manager}<br/>Description: {Desc}" class="{_extraCls} {spanCls} ext-cal-evt ext-cal-evr">',
                      body,
                   '</div>'
                )
                : Ext.create('Ext.XTemplate',
                   '<tpl if="_renderAsAllDay">',
                      '<div data-qtip="<b>{Title}</b><br/>Project: {ProjectCode}<br/>Type: {Type}<br/>Manager: {Manager}<br/>Description: {Desc}" class="{_extraCls} {spanCls} ext-cal-evt ext-cal-evo">',
                         '<div class="ext-cal-evm">',
                            '<div class="ext-cal-evi">',
                   '</tpl>',
                   '<tpl if="!_renderAsAllDay">',
                      '<div data-qtip="<b>{Title}</b><br/>Project: {ProjectCode}<br/>Type: {Type}<br/>Manager: {Manager}<br/>Description: {Desc}" class="{_extraCls} ext-cal-evt ext-cal-evr">',
                   '</tpl>',
                   body,
                   '<tpl if="_renderAsAllDay">',
                            '</div>',
                         '</div>',
                   '</tpl>',
                      '</div>'
                );
             tpl.compile();
             this.eventTpl = tpl;
          }
          return this.eventTpl;
       }
    });
});
