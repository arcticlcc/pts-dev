/**
 * File: app/view/contact/window/PersonGroups.js
 * Description: Person groups tab panel.
 */

Ext.define('PTS.view.contact.window.PersonGroups', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.persongroups',
    requires: [
        'Ext.ux.CheckColumn',
        'Ext.ux.grid.HeaderToolTip',
        'PTS.view.contact.GroupDDList',
        'PTS.view.contact.PersonDDList',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.DragDrop'
    ],

    layout: {
        align: 'stretch',
        padding: 5,
        type: 'hbox'
    },
    title: 'Manage Contact Groups',
    disabled: true,

    initComponent: function() {
        var me = this,
            editor;

        editor = Ext.create('Ext.grid.plugin.CellEditing', {
            itemId: 'contactEditor',
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
                xtype: 'panel',
                itemId: 'contactLists',
                //title: 'Groups',
                style: {
                    borderWidth: '1px 0 0 1px',
                    padding: 0
                },
                activeItem: 1,
                flex: 1,
                layout: {
                    type: 'card'
                },
                defaults: {
                    autoScroll: true,
                    border: 0
                },
                items: [{
                    xtype: 'personddlist',
                    itemId: 'personsList',
                    title: 'Persons',
                    dockedItems: [{
                        xtype: 'toolbar',
                        dock: 'top',
                        items: [{
                            xtype: 'button',
                            iconCls: 'pts-menu-addbasic',
                            text: 'Add Member',
                            action: 'addcontacts'
                        }]
                    }, {
                        xtype: 'pagingtoolbar',
                        store: 'DDPersons',
                        displayInfo: true
                    }]
                }, {
                    xtype: 'groupddlist',
                    itemId: 'groupsList',
                    title: 'Groups',
                    dockedItems: [{
                        xtype: 'toolbar',
                        dock: 'top',
                        items: [{
                            xtype: 'button',
                            iconCls: 'pts-menu-addbasic',
                            text: 'Assign Group',
                            action: 'addcontacts'
                        }]
                    }, {
                        xtype: 'pagingtoolbar',
                        store: 'DDContactGroups',
                        displayInfo: true
                    }]
                }]
            }, {
                xtype: 'gridpanel',
                itemId: 'groupMembersList',
                title: 'Assigned Groups',
                store: 'ContactContactGroups',
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
                    store: 'ContactContactGroups',
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
                        xtype: 'gridcolumn',
                        dataIndex: 'positionid',
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
                            xtype: 'positioncombo',
                            fieldLabel: '',
                            typeAhead: true,
                            forceSelection: true,
                            triggerAction: 'all',
                            //displayField: 'code',
                            //valueField: 'roletypeid',
                            selectOnTab: true,
                            //store: 'RoleTypes',
                            lazyRender: true,
                            listClass: 'x-combo-list-small',
                            queryMode: 'local',
                            /*listConfig: {
                                getInnerTpl: function() {
                                    return '<div data-qtip="{description}">{code}</div>';
                                }
                            },*/
                            listeners: {
                                blur: function(c) {
                                    c.getStore().clearFilter();
                                }
                            }
                        },
                        flex: 2,
                        text: 'Position'
                    }

                ]
            }]
        });

        me.callParent(arguments);
    }
});
