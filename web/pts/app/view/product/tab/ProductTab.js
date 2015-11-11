/**
 * File: app/view/product/ProductTab.js
 * Description: Dashboard calendar displaying deliverables and tasks.
 */

Ext.define('PTS.view.product.tab.ProductTab', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.producttab',
    requires: [
        'PTS.view.product.tab.ProductList' //,
        //'PTS.view.product.tab.ProductDetail'
    ],

    layout: {
        type: 'border'
    },
    title: 'Products',

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            dockedItems: [{
                xtype: 'toolbar',
                //id: 'alccProductToolbar',
                //region: 'center',
                dock: 'top',
                items: [{
                    xtype: 'button',
                    iconCls: 'pts-menu-add',
                    text: 'Add Product',
                    itemId: 'newproductbtn',
                    action: 'addproduct'
                }, {
                    xtype: 'button',
                    iconCls: 'pts-menu-edit',
                    text: 'Edit Product',
                    itemId: 'editproductbtn',
                    action: 'editproduct',
                    disabled: true
                }]
            }],
            items: [{
                xtype: 'productlist',
                region: 'center',
                itemId: 'pts-product-grid'
            }, {
                xtype: 'panel',
                width: 150,
                layout: {
                    type: 'border'
                },
                bodyStyle: {
                    border: 'none',
                    backgroundColor: '#FFF',
                    backgroundImage: 'none'
                },
                collapsible: true,
                animCollapse: !Ext.isIE8, //TODO: remove this IE8 hack
                preventHeader: true,
                title: 'Product Details',
                flex: 1,
                region: 'east',
                split: true,
                defaults: {
                    preventHeader: true
                },
                items: [{
                        //xtype: 'productdetail',
                        //xtype: 'panel',
                        //title: 'Product Details',
                        region: 'center'
                    }
                    /*,
                                            {
                                                //xtype: 'productdetailscsm',
                                                xtype: 'panel',
                                                flex: 1,
                                                region: 'south',
                                                split: true
                                            }*/
                ]
            }]
        });

        me.callParent(arguments);
    }
});
