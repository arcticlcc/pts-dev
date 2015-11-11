/**
 * File: app/view/product/window/Window.js
 * Description: Product window containing tab panel.
 */
Ext.define('PTS.view.product.window.Window', {
    extend: 'Ext.window.Window',
    alias: 'widget.productwindow',
    requires: [
        'PTS.view.product.form.ProductForm',
        'PTS.view.product.window.ProductLinks',
        'PTS.view.product.window.ProductStatus',
        'PTS.view.product.window.ProductContacts',
        'PTS.view.product.window.ProductMetadata',
        'PTS.view.product.form.ProductMetadataForm',
        //'PTS.view.controls.CommentEditGrid',
        'PTS.view.product.window.ProductKeywords',
        'PTS.view.project.ProjectMap',
        'GeoExt.selection.FeatureModel',
        'Ext.grid.plugin.CellEditing'
    ],

    height: Ext.Element.getViewportHeight() - 40,
    minWidth: 750,
    width: 900,
    layout: {
        type: 'fit'
    },

    /**
     * @cfg {Boolean} closable
     * This needs to be set to false since we're using a
     * custom close tool.
     */
    closable: false,
    maximizable: true,
    title: 'Edit Product',
    constrain: true,
    modal: true,
    y: 10,

    /**
     * Adds the custom close tool.
     */
    addTools: function() {
        var me = this;

        // Call Panel's initTools
        me.callParent();

        me.addTool({
            xtype: 'tool',
            type: 'close',
            action: 'closewindow'
        });
    },

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [{
                xtype: 'tabpanel',
                itemId: 'producttabpanel',
                items: [{
                        xtype: 'productform'
                    }, {
                        xtype: 'productlinks'
                    }, {
                        xtype: 'productstatus'
                    }, {
                        xtype: 'productcontacts'
                    },
                    /*{
                        title: 'Comments',
                        xtype: 'commenteditgrid',
                        store: 'ProductComments'
                    },*/
                    {
                        xtype: 'productkeywords'
                    }, {
                        xtype: 'panel',
                        defaults: {
                            preventHeader: true
                        },
                        layout: {
                            type: 'border'
                        },
                        title: 'Map',
                        items: [{
                            xtype: 'projectmap',
                            commonStore: 'CommonVectors',
                            //center: '-130.95977783203,10.914916992189',
                            center: '-16760019.526289, 9118642.6397498',
                            zoom: 4,
                            region: 'center',
                            layerName: 'Product Features',
                            layerUrl: '../productfeature'
                        }, {
                            xtype: 'gridpanel',
                            itemId: 'featureGrid',
                            store: 'ProductVectors',
                            height: 250,
                            split: true,
                            autoScroll: true,
                            title: 'Feature List',
                            region: 'south',
                            columns: [{
                                xtype: 'gridcolumn',
                                dataIndex: 'name',
                                flex: 1,
                                text: 'Name',
                                editor: {
                                    xtype: 'textfield',
                                    allowBlank: false
                                }
                            }, {
                                xtype: 'gridcolumn',
                                dataIndex: 'comment',
                                flex: 2,
                                text: 'Description',
                                editor: {
                                    xtype: 'textfield',
                                    allowBlank: false
                                }
                            }],
                            selModel: {
                                //autoPanMapOnSelection: true,
                                selectControl: {
                                    id: 'PTS-Select-Row'
                                }
                            },
                            selType: 'featuremodel',
                            plugins: [
                                Ext.create('Ext.grid.plugin.CellEditing', {
                                    pluginId: 'cellEdit',
                                    clicksToEdit: 1
                                })
                            ]
                        }]
                    }, {
                        xtype: 'productmetadata',
                        formItems: [{
                            xtype: 'productmetadataform'
                        }]
                    }
                ]
            }],
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                        xtype: 'tbfill'
                    },
                    /*{//TODO: save all button
                        xtype: 'button',
                        text: 'Save All',
                        action: 'saveall'
                    },*/
                    {
                        xtype: 'button',
                        text: 'Close',
                        action: 'closewindow'
                    }
                ]
            }]
        });

        me.callParent(arguments);
    }
});
