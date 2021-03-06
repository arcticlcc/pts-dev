/**
 * Various Overrides for ExtJS.
 */
Ext.define('PTS.Overrides', {
    singleton: true,
    requires: [
        'Ext.form.field.Radio',
        'Ext.data.AbstractStore',
        'Ext.data.Store',
        'Ext.data.proxy.Proxy',
        'Ext.view.AbstractView',
        'Ext.form.field.ComboBox',
        'Extensible.calendar.view.Month',
        'Ext.grid.RowEditor',
        'Ext.Array',
        'Ext.util.Sorter',
        'Ext.data.TreeStore',
        'Ext.grid.Scroller',
        'Ext.button.Cycle',
        'Ext.data.Model',
        'Ext.form.action.Submit'

    ]
}, function() {
    //This method is included in 4.1, required by GeoExt
    Ext.override(Ext.data.Model, {
        compatibility: '4',

        /**
         * Gets all values for each field in this model and returns an object
         * containing the current data.
         * @param {Boolean} includeAssociated True to also include associated
         * data. Defaults to false.
         * @return {Object} An object hash containing all the values in this
         * model
         */
        getData: function(includeAssociated) {
            var me = this,
                fields = me.fields.items,
                fLen = fields.length,
                data = {},
                name,
                f;

            for (f = 0; f < fLen; f++) {
                name = fields[f].name;
                data[name] = me.get(name);
            }

            if (includeAssociated === true) {
                Ext.apply(data, me.getAssociatedData());
            }
            return data;
        }
    });

    //Fixes Chrome 43 menu bug
    //https://www.sencha.com/forum/announcement.php?f=80&a=58
    Ext.override(Ext.menu.Menu, {

        compatibility: '4',

        onMouseLeave: function(e) {
            var me = this;

            // If the mouseleave was into the active submenu, do not dismiss
            if (me.activeChild) {
                if (e.within(me.activeChild.el, true)) {
                    return;
                }
            }
            me.deactivateActiveItem();
            if (me.disabled) {
                return;
            }
            me.fireEvent('mouseleave', me, e);
        }
    });

    //Fixes bug when filtering store with pagingtoolbar enabled
    //TODO: Fixed in 4.1
    //http://www.sencha.com/forum/showthread.php?182179-Store-filter-and-paging-doesn-t-load-first-page
    //Fixes bug causing store to autoload when attached to combobox
    //https://www.sencha.com/forum/showthread.php?257321-Combo-with-store-triggers-store-load-without-autoLoad&p=946177&viewfull=1#post946177
    Ext.override(Ext.data.Store, {
        filter: function(filters, value) {
            if (Ext.isString(filters)) {
                filters = {
                    property: filters,
                    value: value
                };
            }

            var me = this,
                decoded = me.decodeFilters(filters),
                i = 0,
                doLocalSort = me.sortOnFilter && !me.remoteSort,
                length = decoded.length,
                allDisabled = true;

            for (; i < length; i++) {
                me.filters.replace(decoded[i]);
            }

            // Check that we have some enabled filters before attempting to filter
            for (i = 0, length = me.filters.items.length; i < length; i++) {
                if (!me.filters.items[i].disabled) {
                    allDisabled = false;
                    break;
                }
            }

            if (!allDisabled) {
                if (me.remoteFilter) {
                    //****Copied from 4.1****
                    // So that prefetchPage does not consider the store to be fully loaded if the local count is equal to the total count
                    delete me.totalCount;

                    // For a buffered Store, we have to clear the prefetch cache because the dataset will change upon filtering.
                    // Then we must prefetch the new page 1, and when that arrives, reload the visible part of the Store
                    // via the guaranteedrange event
                    if (me.buffered) {
                        me.pageMap.clear();
                        me.loadPage(1);
                    } else {
                        // Reset to the first page, the filter is likely to produce a smaller data set
                        me.currentPage = 1;
                        //the load function will pick up the new filters and request the filtered data from the proxy
                        me.load();
                    }
                    //******
                } else {
                    /**
                     * A pristine (unfiltered) collection of the records in this store. This is used to reinstate
                     * records when a filter is removed or changed
                     * @property snapshot
                     * @type Ext.util.MixedCollection
                     */
                    if (me.filters.getCount()) {
                        me.snapshot = me.snapshot || me.data.clone();
                        me.data = me.data.filter(me.filters.items);

                        if (doLocalSort) {
                            me.sort();
                        }
                        // fire datachanged event if it hasn't already been fired by doSort
                        if (!doLocalSort || me.sorters.length < 1) {
                            me.fireEvent('datachanged', me);
                        }
                    }
                }
            }
        }
    });

    //RowEditor ignores errorSummary
    //http://www.sencha.com/forum/showthread.php?132214
    //Fixed in 4.1
    Ext.override(Ext.grid.RowEditor, {
        loadRecord: function(record) {
            var me = this,
                form = me.getForm();
            form.loadRecord(record);

            if (form.isValid()) {
                me.hideToolTip();
            } else if (me.errorSummary) {
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

            if (null !== v1 && null !== v2) { //neither value is null
                return v1 > v2 ? 1 : (v1 < v2 ? -1 : 0);

            } else if (v1 === v2) { //both values are null
                return 0;

            } else { //one value is null
                return v1 === null ? 1 : -1;

            }
        }
    });
    //fix loadmask issue, still happens with masked views that are visible behind modal
    //http://www.sencha.com/forum/showthread.php?150040-Unexplained-load-mask-in-upper-left-corner-of-browser-again/page4
    Ext.override(Ext.view.AbstractView, {
        onMaskBeforeShow: function() {
            if (!this.el.isVisible(true)) {
                return false;
            }
            this.callOverridden(arguments);
        },
        //fix Ext.view.View itemadd event bug
        //TODO: fixed in  4.1.2
        //http://www.sencha.com/forum/showthread.php?142914-Ext.view.View-itemadd-event-bug
        onAdd: function(ds, records, index) {
            var me = this,
                nodes;

            if (me.all.getCount() === 0) {
                me.refresh();
            } else {
                nodes = me.bufferRender(records, index);
                me.doAdd(nodes, records, index);

                me.selModel.refresh();
                me.updateIndexes(index);
            }

            me.fireEvent('itemadd', records, index, nodes);
        }
    });
    //http://www.sencha.com/forum/showthread.php?182524-RadioField-and-isDirty-problem&p=745308&viewfull=1#post745308
    //http://stackoverflow.com/questions/6490845/extjs-4-issue-with-a-radiogroup-which-is-always-dirty
    Ext.override(Ext.form.field.Radio, {
        resetOriginalValue: function() {
            //Override the original method in Ext.form.field.Field:
            //this.originalValue = this.getValue();
            //this.checkDirty();
            this.getManager().getByName(this.name).each(function(item) {
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
        },

        //Adds rejectChanges.
        //TODO: Fixed in 4.1
        //http://www.sencha.com/forum/showthread.php?136871-Where-did-rejectChanges%28%29-go
        getModifiedRecords: function() {
            return [].concat(this.getNewRecords(), this.getUpdatedRecords());
        },

        rejectChanges: function() {
            var me = this,
                recs = me.getModifiedRecords(),
                len = recs.length,
                i = 0;

            for (; i < len; i++) {
                recs[i].reject();
                if (recs[i].phantom) {
                    me.remove(recs[i]);
                }
            }

            recs = me.removed;
            len = recs.length;

            for (i = 0; i < len; i++) {
                me.insert(recs[i].lastIndex || 0, recs[i]);
                recs[i].reject();
                // lastIndex will get re-added if this rec gets removed again later
                delete recs[i].lastIndex;
            }

            // Since removals are cached in a simple array we can simply reset it here.
            // Adds and updates are managed in the data MixedCollection and should already be current.
            me.removed.length = 0;
        }
    });

    Ext.override(Ext.data.proxy.Proxy, {
        batch: function(options, /* deprecated */ listeners) {
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
                                action: action,
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
        getEventTemplate: function() {
            if (!this.eventTpl) {
                var tpl, body = this.getEventBodyMarkup();

                tpl = !(Ext.isIE || Ext.isOpera) ?
                    Ext.create('Ext.XTemplate',
                        '<div data-qtip="<b>{Title}</b><br/>Status: {Status}<br/>Project: {ProjectCode}<br/>Project Title: {ProjectTitle}<br/>Type: {Type}<br/>Manager: {Manager}<br/>Description: {Desc}" class="{_extraCls} {spanCls} ext-cal-evt ext-cal-evr">',
                        body,
                        '</div>'
                    ) : Ext.create('Ext.XTemplate',
                        '<tpl if="_renderAsAllDay">',
                        '<div data-qtip="<b>{Title}</b><br/>Status: {Status}<br/>Project: {ProjectCode}<br/>Project Title: {ProjectTitle}<br/>Type: {Type}<br/>Manager: {Manager}<br/>Description: {Desc}" class="{_extraCls} {spanCls} ext-cal-evt ext-cal-evo">',
                        '<div class="ext-cal-evm">',
                        '<div class="ext-cal-evi">',
                        '</tpl>',
                        '<tpl if="!_renderAsAllDay">',
                        '<div data-qtip="<b>{Title}</b><br/>Status: {Status}<br/>Project: {ProjectCode}<br/>Project Title: {ProjectTitle}<br/>Type: {Type}<br/>Manager: {Manager}<br/>Description: {Desc}" class="{_extraCls} ext-cal-evt ext-cal-evr">',
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
    //Fixes clearonload when using REST, from 4.1
    //TODO: Fixed in 4.1
    //http://www.sencha.com/forum/showthread.php?151211-Reloading-TreeStore-adds-all-records-to-store-getRemovedRecords&p=661157
    Ext.override(Ext.data.TreeStore, {
        load: function(options) {
            options = options || {};
            options.params = options.params || {};

            var me = this,
                node = options.node || me.tree.getRootNode();

            // If there is not a node it means the user hasnt defined a rootnode yet. In this case lets just
            // create one for them.
            if (!node) {
                node = me.setRootNode({
                    expanded: true
                }, true);
            }

            // Assign the ID of the Operation so that a ServerProxy can set its idParam parameter,
            // or a REST proxy can create the correct URL
            options.id = node.getId();

            if (me.clearOnLoad) {
                if (me.clearRemovedOnLoad) {
                    // clear from the removed array any nodes that were descendants of the node being reloaded so that they do not get saved on next sync.
                    me.clearRemoved(node);
                }
                // temporarily remove the onNodeRemove event listener so that when removeAll is called, the removed nodes do not get added to the removed array
                me.tree.un('remove', me.onNodeRemove, me);
                // remove all the nodes
                node.removeAll(false);
                // reattach the onNodeRemove listener
                me.tree.on('remove', me.onNodeRemove, me);
            }

            Ext.applyIf(options, {
                node: node
            });

            if (node) {
                node.set('loading', true);
            }

            return me.callParent([options]);
        }
    });
    //Fixes grid scrolling issues when in a container with 'fit' layout
    //http://www.sencha.com/forum/showthread.php?137993-4.0.2-only-layout-fit-grid-scrollbar-when-used-does-not-scroll-content/page4
    //http://stackoverflow.com/questions/6835618/extjs-4-grid-autoscroll?rq=1
    //TODO: Fixed in 4.1
    //
    Ext.override(Ext.grid.Scroller, {
        onAdded: function() {
            this.callParent(arguments);
            var me = this;
            if (me.scrollEl) {
                me.mun(me.scrollEl, 'scroll', me.onElScroll, me);
                me.mon(me.scrollEl, 'scroll', me.onElScroll, me);
            }
        }
    });

    //jsonData support for form submits
    Ext.override(Ext.form.action.Submit, {
      doSubmit: function() {
          var formEl,
              ajaxOptions = Ext.apply(this.createCallback(), {
                  url: this.getUrl(),
                  method: this.getMethod(),
                  headers: this.headers
              });

          // For uploads we need to create an actual form that contains the file upload fields,
          // and pass that to the ajax call so it can do its iframe-based submit method.
          if (this.form.hasUpload()) {
              formEl = ajaxOptions.form = this.buildForm();
              ajaxOptions.isUpload = true;
          } else {
              ajaxOptions.params = this.getParams();
              ajaxOptions.jsonData = this.jsonData;
          }

          Ext.Ajax.request(ajaxOptions);

          if (formEl) {
              Ext.removeNode(formEl);
          }
      },

      getParams: function() {
          var nope = false,
              configParams = this.callParent(),
              fieldParams = this.jsonData ? null : this.form.getValues(nope, nope, this.submitEmptyText !== nope);
          return Ext.apply({}, fieldParams, configParams);
      }
    });

    //Fixes Ext.button.Cycle suppressEvent
    //see http://www.sencha.com/forum/showthread.php?p=1033531&viewfull=1#post1033531
    Ext.override(Ext.CycleButton, {
        setActiveItem: function(item, suppressEvent) {
            var me = this;

            if (!Ext.isObject(item)) {
                item = me.menu.getComponent(item);
            }
            if (item) {
                if (!me.rendered) {
                    me.text = me.getButtonText(item);
                    me.iconCls = item.iconCls;
                } else {
                    me.setText(me.getButtonText(item));
                    me.setIconCls(item.iconCls);
                }
                me.activeItem = item;
                if (!item.checked) {
                    item.setChecked(true, suppressEvent);
                }
                if (me.forceIcon) {
                    me.setIconCls(me.forceIcon);
                }
                if (!suppressEvent) {
                    me.fireEvent('change', me, item);
                }
            }
        }
    });

    //Add qtip support to form fields
    Ext.override(Ext.form.field.Base, {
        labelableRenderTpl: [
            '<tpl if="!hideLabel && !(!fieldLabel && hideEmptyLabel)">',
            '<label id="{id}-labelEl"<tpl if="inputId"> for="{inputId}"</tpl> class="{labelCls}"',
            '<tpl if="labelStyle"> style="{labelStyle}"</tpl>>',
            '<tpl if="fieldLabel">{fieldLabel}',
            '<tpl if="qtip"><span class="pts-field-tip" data-qtip="{qtip}">&nbsp;</span></tpl>',
            '{labelSeparator}</tpl>',
            '</label>',
            '</tpl>',
            '<div class="{baseBodyCls} {fieldBodyCls}" id="{id}-bodyEl" role="presentation">{subTplMarkup}</div>',
            '<div id="{id}-errorEl" class="{errorMsgCls}" style="display:none"></div>',
            '<div class="{clearCls}" role="presentation"><!-- --></div>', {
                compiled: true,
                disableFormats: true
            }
        ],
        getLabelableRenderData: function() {
            var me = this,
                labelAlign = me.labelAlign,
                labelCls = me.labelCls,
                labelClsExtra = me.labelClsExtra,
                labelPad = me.labelPad,
                labelStyle;

            // Calculate label styles up front rather than in the Field layout for speed; this
            // is safe because label alignment/width/pad are not expected to change.
            if (labelAlign === 'top') {
                labelStyle = 'margin-bottom:' + labelPad + 'px;';
            } else {
                labelStyle = 'margin-right:' + labelPad + 'px;';
                // Add the width for border-box browsers; will be set by the Field layout for content-box
                if (Ext.isBorderBox) {
                    labelStyle += 'width:' + me.labelWidth + 'px;';
                }
            }
            return Ext.copyTo({
                    inputId: me.getInputId(),
                    fieldLabel: me.getFieldLabel(),
                    labelCls: labelClsExtra ? labelCls + ' ' + labelClsExtra : labelCls,
                    labelStyle: labelStyle + (me.labelStyle || ''),
                    subTplMarkup: me.getSubTplMarkup()
                },
                me,
                'hideLabel,hideEmptyLabel,fieldBodyCls,baseBodyCls,errorMsgCls,clearCls,labelSeparator,qtip',
                true
            );
        }
    });
});
