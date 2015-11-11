/**
 * Form for editing basic metadata.
 */

Ext.define('PTS.view.project.form.MetadataForm', {
    extend: 'Ext.form.Panel',
    alias: 'widget.metadataform',
    requires: [
        'Ext.ux.form.ItemSelector', 'Ext.ux.form.BoxSelect'
    ],

    autoScroll: true,
    bodyPadding: 5,
    border: 0,
    //title: 'Project Metadata',

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
            }, {
                xtype: 'itemselector',
                name: 'projectcategory',
                anchor: '100%',
                fieldLabel: 'Project Categories',
                delimiter: null,
                store: 'ProjectCategories',
                displayField: 'category',
                valueField: 'projectcategoryid',
                //allowBlank : false,
                msgTarget: 'side',
                style: {
                    marginBottom: '25px'
                }
            }, {
                xtype: 'itemselector',
                name: 'usertype',
                anchor: '100%',
                fieldLabel: 'User Types',
                delimiter: null,
                store: 'UserTypes',
                displayField: 'usertype',
                valueField: 'usertypeid',
                //allowBlank : false,
                msgTarget: 'side'
            }]
        });

        me.callParent(arguments);
    }
});
