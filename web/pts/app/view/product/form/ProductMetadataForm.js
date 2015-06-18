/**
 * Form for editing basic metadata.
 */

Ext.define('PTS.view.product.form.ProductMetadataForm', {
    extend: 'Ext.form.Panel',
    alias: 'widget.productmetadataform',
    requires: [
        'Ext.ux.form.ItemSelector', 'Ext.ux.form.BoxSelect'
    ],

    autoScroll: true,
    bodyPadding: 5,
    border: 0,
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
            items:[{
                xtype : 'boxselect',
                name: 'topiccategory',
                fieldLabel : 'Topic Categories',
                anchor : '100%',
                store : 'TopicCategories',
                displayField : 'codename',
                valueField : 'topiccategoryid',
                allowBlank : false,
                listConfig: {
                    getInnerTpl: function() {
                        return '<div data-qtip="{description}">{codename}</div>';
                    }
                },
                //labelWidth : 130,
                emptyText : 'Pick one or more categories',
                queryMode : 'local',
                style : {
                    marginBottom : '25px'
                }
            }]
        });

        me.callParent(arguments);
    }
});
