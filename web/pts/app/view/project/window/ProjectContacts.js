/**
 * File: app/view/project/window/ProjectContacts.js
 * Description: Project Contacts tab panel.
 */

Ext.define('PTS.view.project.window.ProjectContacts', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.projectcontacts',
    requires: [
        'Ext.ux.CheckColumn',
        'Ext.ux.grid.HeaderToolTip',
        'PTS.view.contact.ContactLists',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.DragDrop'
    ],

    layout: {
        align: 'stretch',
        padding: 5,
        type: 'hbox'
    },
    title: 'Contacts',

    initComponent: function() {
        var me = this,
            editor;

        editor = Ext.create('Ext.grid.plugin.CellEditing', {
            itemId: 'contactEditor',
            pluginId: 'contactEditor',
            clicksToEdit: 1,
            listeners: { //TODO: move to controller??
                beforeedit: function(event) { //needed to prevent editing of selection checkbox
                    if (event.column && (event.column.isCheckerHd || event.column.is('actioncolumn'))) {
                        return false;
                    }

                    return true;
                }
            }
        });

        Ext.applyIf(me, {
            items: [{
                xtype: 'contactlists',
                flex: 1
            }, {
                xtype: 'gridpanel',
                itemId: 'projectContactsList',
                title: 'Project Contacts',
                store: 'ProjectContacts',
                flex: 1,
                selModel: Ext.create('Ext.selection.CheckboxModel', {
                    injectCheckbox: false,
                    mode: 'SIMPLE',
                    checkOnly: true
                }),
                plugins: [
                    editor,
                    'headertooltip'
                ],
                viewConfig: {
                    plugins: [{
                        ptype: 'gridviewdragdrop',
                        pluginId: 'contactsddplugin'
                    }]
                },
                dockedItems: [{
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [{
                        xtype: 'button',
                        iconCls: 'pts-menu-deletebasic',
                        text: 'Remove',
                        action: 'removecontacts'
                    }, {
                        xtype: 'button',
                        iconCls: 'pts-menu-savebasic',
                        text: 'Save',
                        action: 'savecontacts'
                    }, {
                        xtype: 'button',
                        iconCls: 'pts-menu-refresh',
                        text: 'Refresh',
                        action: 'refreshcontacts'
                    }]
                }, {
                    xtype: 'pagingtoolbar',
                    store: 'ProjectContacts',
                    displayInfo: true
                }],
                columns: [{
                        xtype: 'gridcolumn',
                        sortable: false,
                        dataIndex: 'name',
                        flex: 1,
                        text: 'Name'
                    },
                    /*{
                        xtype: 'gridcolumn',
                        sortable: false,
                        dataIndex: 'desc',
                        flex: 1,
                        text: 'Description'
                    },*/
                    {
                        xtype: 'gridcolumn', //TODO: add xtype with generic renderer
                        dataIndex: 'roletypeid',
                        renderer: function(value, metaData, record, rowIdx, colIdx, store, view) {
                            var combo = view.getHeaderAtIndex(colIdx).getEditor(),
                                idx = combo.getStore().find(combo.valueField, value, 0, false, true, true),
                                rec = combo.getStore().getAt(idx);
                            if (rec) {
                                return rec.get(combo.displayField);
                            }
                            return value;
                        },
                        editor: {
                            xtype: 'combobox',
                            itemId: 'roletypeCbxProject',
                            typeAhead: true,
                            forceSelection: true,
                            triggerAction: 'all',
                            displayField: 'code',
                            valueField: 'roletypeid',
                            selectOnTab: true,
                            store: 'RoleTypes',
                            lazyRender: true,
                            listClass: 'x-combo-list-small',
                            queryMode: 'local',
                            listConfig: {
                                getInnerTpl: function() {
                                    return '<div data-qtip="{description}">{code}</div>';
                                }
                            },
                            listeners: {
                                blur: function(c) {
                                    c.getStore().clearFilter();
                                }
                            }
                        },
                        flex: 1,
                        text: 'Role'
                    }, {
                        xtype: 'checkcolumn',
                        itemId: 'reminderCbx',
                        dataIndex: 'reminder',
                        text: 'Notice?',
                        width: 55,
                        tooltip: 'Receive reminder notices?'
                    }, {
                        xtype: 'checkcolumn',
                        dataIndex: 'partner',
                        text: 'Partner?',
                        width: 55,
                        tooltip: 'Identify contact as partner for reporting.'
                    }

                ]
            }]
        });

        me.callParent(arguments);
    }
});
