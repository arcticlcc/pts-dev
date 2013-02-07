/**
 * Controller for ContactDetail
 */
Ext.define('PTS.controller.contact.tab.ContactTabDetail', {
    extend: 'Ext.app.Controller',
    stores: [
        'ContactProjects',
        'PersonGroups'
    ],
    views: [
        'contact.tab.ContactTabDetail'
    ],
    refs: [{
        ref: 'contactDetail',
        selector: 'contacttab contacttabdetail'
    },{
        ref: 'contactLists',
        selector: 'contacttab contacttabdetail #contactLists'
    }],

    init: function() {

       this.control({
            /*'contacttabdetail > #contactProjects': {
                itemdblclick: this.onDeliverableDblClick
            },
            'contacttabdetail > #projectContacts': {
                itemdblclick: this.onContactDblClick
            },
            'contacttabdetail > deliverablelist #printBtn': {
                render: this.onDelPrintBtnRender
            },*/
            'contacttab contacttabdetail tab': {
                activate: this.onContactDetailTabActivate
            },
            'contacttab contacttabdetail #contactLists': {
                activate: this.onContactDetailListsActivate
            }
        });

        // We listen for the application-wide events
        this.application.on({
            contactlistselect: this.onSelectContact,
            contactlistactivate: this.onContactListActivate,
            scope: this
        });
    },

    /**
     * Fired when a contact is selected.
     */
    onSelectContact: function(record) {
        var id = record.getId(),
            type = record.getContactType() === 'group' ? 0 : 1,
            detail = this.getContactDetail(),
            store = detail.getActiveTab().getStore(),
            lists = this.getContactLists(),
            grids,
            projectFilter = {
                property: 'contactids',
                value: [
                    'where in array',
                    id
                ]
            },
            printTitle = 'Projects for ',
            contactFilter;

            //set the contact filter, person and groups use the same store
            //set the title for the lists tab and project printer
            if(type === 0) {
                contactFilter = {
                    property: 'groupids',
                    value: [
                        'where in array',
                        id
                    ]
                };

                lists.setTitle('Persons');
                printTitle += record.get('fullname');
            }else {
                contactFilter = {
                    property: 'contactid',
                    value: id
                };

                lists.setTitle('Groups');
                printTitle += record.getContactName();
            }

            //activate the correct card
            if(lists.rendered) {
                lists.getLayout().setActiveItem(type);
            }

            //apply filters
            grids = [
                [this.getContactProjectsStore(), projectFilter],
                [this.getPersonGroupsStore(), contactFilter]
            ];
            Ext.each(grids, function(i){
                var g = i[0];
                //TODO: Fixed in 4.1?
                //http://www.sencha.com/forum/showthread.php?139210-3461-ExtJS4-store-suspendEvents-clearFilter-problem
                g.remoteFilter = false;
                g.clearFilter(true);
                g.filter(i[1]);
                g.remoteFilter = true;
            });

            //load the active store
            store.load();

            this.contactRecord = record;
            this.updateProjectsPrintBtnTitle(printTitle);

    },

    /**
     * ContactList activate handler
     * @param {Ext.grid.Panel} tab
     */
    onContactListActivate: function(grid) {
        var record = grid.getSelectionModel().getSelection()[0];

        if(record) {this.onSelectContact(record);}
    },

    /**
     * Contact Detail Tabs activate handler
     * @param {Ext.tab.Tab} tab
     */
    onContactDetailTabActivate: function(tab) {
        tab.card.getStore().load();
    },

    /**
     * ContactTabDetail lists activate handler
     * @param {Ext.tab.Tab} tab
     */
    onContactDetailListsActivate: function(tab) {
        var type = this.contactRecord.getContactType() === 'group' ? 0 : 1;

        tab.getLayout().setActiveItem(type);
    },

    /**
     * Updates ContactProjects grid print title.
     * @param {Ext.Component} btn
     */
    updateProjectsPrintBtnTitle: function(title) {
        var btn = this.getContactDetail().down('#contactProjects #printBtn');

        btn.mainTitle = function(){
            return title;
        };
    }//,

    /**
     * Updates ProjectContacts grid print title.
     * @param {Ext.Component} btn
     */
    /*onContactPrintBtnRender: function(btn) {
        var code = this.projectRecord.get('projectcode');

        btn.mainTitle = function(){
            return 'Project Contacts for ' + code;
        };
    },*/

    /**
     * ProjectDeliverables grid double click handler
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    /*onDeliverableDblClick: function(view, rec) {
        var id = rec.getId(),
            modid = rec.get('modificationid'),
            setPath = function(store) {
                    var path = store.getNodeById("d-"+id+"-"+modid).getPath();
                    this.down('agreementstree').selectPath(path);
                    this.getEl().unmask();
                };
            this.openProjectAgreement(setPath);
            return false;
    },*/

    /**
     * ProjectContacts grid double click handler
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    /*onContactDblClick: function(view, rec) {
        var id = rec.get('contactid'),
            name = rec.get('name').split(' -> ').pop(), //need to split nested fullnames
            type = rec.get('type'),
            record = {
                getId: function() {return id;},
                getContactName: function() {return name;}
            };

            this.getController('contact.Contact').openContact(type, record);
            return false;
    },*/

    /**
     * Open the project window
     * @param {function} path The function that returns the path
     * to expand in the {@link PTS.view.project.window.AgreementsTree AgreementsTree}.
     * The function scope is the {@link PTS.view.project.window.Window ProjectWindow}.
     */
    /*openProjectAgreement: function(setPath) {
        var callBack = function() {
            var win = this,
                store = win.down('agreementstree').getStore(),
                tab = win.down('projectagreements');

            //Ext.getBody().unmask();
            win.getEl().mask('Loading...');
            win.down('tabpanel').setActiveTab(tab);

            if(store.getRootNode().hasChildNodes()) {
                setPath(store);
            }else {
                store.on('load', setPath, win, {
                    single: true
                });
            }
        };
        this.getController('project.Project').openProject(this.projectRecord, callBack);
    }*/
});
