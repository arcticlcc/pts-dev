/**
 * Form for editing basic metadata.
 */

Ext.define('PTS.view.product.form.ProductMetadataForm', {
    extend: 'Ext.form.Panel',
    alias: 'widget.productmetadataform',
    requires: ['Ext.ux.form.ItemSelector', 'Ext.ux.form.BoxSelect'],

    autoScroll: true,
    bodyPadding: 5,
    border: 0,
    submitEmptyText: false,
    //title: 'Product Metadata',

    initComponent: function() {
        var me = this;

        me.initialConfig = Ext.apply({
            trackResetOnLoad: true
        }, me.initialConfig);

        Ext.applyIf(me, {
            defaults: {
                validateOnChange: true
            },
            items: [{
                xtype: 'boxselect',
                name: 'topiccategory',
                fieldLabel: 'Topic Categories',
                anchor: '100%',
                store: 'TopicCategories',
                displayField: 'codename',
                valueField: 'topiccategoryid',
                allowBlank: false,
                listConfig: {
                    getInnerTpl: function() {
                        return '<div data-qtip="{description}">{codename}</div>';
                    }
                },
                //labelWidth : 130,
                emptyText: 'Pick one or more categories',
                queryMode: 'local',
                style: {
                    marginBottom: '25px'
                }
            },{
                xtype: 'boxselect',
                fieldLabel: 'Spatial Format',
                name: 'spatialformat',
                displayField: 'codename',
                listConfig: {
                    getInnerTpl: function() {
                        return '<div>{codename}: {description}</div>';
                    }
                },
                store: 'SpatialFormats',
                valueField: 'spatialformatid',
                forceSelection: true,
                allowBlank: true,
                queryMode: 'local',
                anchor: '50%',
                emptyText: 'Pick one or more spatial formats, if applicable',
                style: {
                    marginBottom: '25px'
                }
            }, {
                xtype: 'fieldset',
                collapsible: true,
                title: 'Spatial Reference System',
                anchor: '-15',
                padding: 15,
                items: [{
                    xtype: 'boxselect',
                    name: 'epsgcode',
                    fieldLabel: 'EPSG Code',
                    anchor: '100%',
                    store: 'EpsgCodes',
                    displayField: 'srid_text',
                    valueField: 'srid_text',
                    allowBlank: true,
                    triggerOnClick: false,
                    hideTrigger: true,
                    listConfig: {
                        getInnerTpl: function() {
                            return '<div data-qtip="{name}">{srid}: {name}</div>';
                        }
                    },
                    //labelWidth : 130,
                    emptyText: 'Pick one or more EPSG codes, if applicable',
                    queryMode: 'remote',
                    queryParam: 'filter',
                    style: {
                        marginBottom: '25px'
                    }
                }, {
                    xtype: 'textareafield',
                    fieldLabel: 'WKT Format(pipe-delimited)',
                    emptyText: 'Enter valid WKT projection strings separated by a pipe(|) , if applicable',
                    name: 'wkt',
                    allowBlank: true,
                    grow: true,
                    growMin: 80,
                    anchor: '100%'
                }]
            }]
        });

        me.callParent(arguments);
    }
});
