/**
 * Controller for ProjectDetail
 */
Ext.define('PTS.controller.project.tab.ProjectDetail', {
    extend: 'Ext.app.Controller',
    stores: [
        'ProjectAgreementsTree',
        'ProjectDeliverables',
        'ProjectContacts'
    ],
    models: [
        'AgreementsTree'
    ],
    views: [
        'project.tab.ProjectDetail'
    ],
    refs: [{
        ref: 'projectAgreements',
        selector: 'projectdetail > #projectAgreements'
    },{
        ref: 'projectDetail',
        selector: 'projecttab projectdetail'
    }],

    init: function() {

       this.control({
            'projectdetail > #projectAgreements': {
                beforeitemdblclick: this.onProjectAgreementsDblClick//,
                //itemclick: this.onProjectAgreementsClick
            },
            'projectdetail > deliverablelist': {
                itemdblclick: this.onDeliverableDblClick
            },
            'projectdetail > #projectContacts': {
                itemdblclick: this.onContactDblClick
            },
            'projectdetail > deliverablelist #printBtn': {
                render: this.onDelPrintBtnRender
            },
            'projectdetail > #projectContacts #printBtn': {
                render: this.onContactPrintBtnRender
            },
            'projecttab projectdetail tab': {
                activate: this.onProjectDetailTabActivate
            }
        });

        // We listen for the application-wide events
        this.application.on({
            projectlistselect: this.onSelectProject,
            scope: this
        });
    },

    /**
     * Fired when a project is selected.
     */
    onSelectProject: function(record) {
        var id = record.getId(),
            detail = this.getProjectDetail(),
            grids = detail.query('treepanel, grid');

            Ext.each(grids, function(grid){
                grid.getStore().setProxy({
                    type: 'ajax',
                    url : '../project/' + id + '/' + grid.uri,
                    reader: {
                        type: 'json',
                        root: grid.isXType('grid') ? 'data' : ''
                    }
                });
            });

            //load the store
            detail.getActiveTab().getStore().load();

            this.projectRecord = record;
    },

    /**
     * Project Detail Tabs activate handler
     * @param {Ext.tab.Tab} tab
     */
    onProjectDetailTabActivate: function(tab) {
        tab.card.getStore().load();
    },

    /**
     * Updates ProjectDeliverables grid print title.
     * @param {Ext.Component} btn
     */
    onDelPrintBtnRender: function(btn) {
        var code = this.projectRecord.get('projectcode');

        btn.mainTitle = function(){
            return this.child('cycle#filter').getActiveItem().text + ' Deliverables for ' + code;
        };
    },

    /**
     * Updates ProjectContacts grid print title.
     * @param {Ext.Component} btn
     */
    onContactPrintBtnRender: function(btn) {
        var code = this.projectRecord.get('projectcode');

        btn.mainTitle = function(){
            return 'Project Contacts for ' + code;
        };
    },

    /**
     * ProjectAgreements grid double click handler
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    onProjectAgreementsDblClick: function(view, rec) {
            var path = rec.getPath(),
                setPath = function(store) {
                this.down('agreementstree').selectPath(path);
                this.getEl().unmask();
            };
            this.openProjectAgreement(setPath);
            return false;
    },

    /**
     * ProjectDeliverables grid double click handler
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    onDeliverableDblClick: function(view, rec) {
        var id = rec.getId(),
            modid = rec.get('modificationid'),
            setPath = function(store) {
                    var path = store.getNodeById("d-"+id+"-"+modid).getPath();
                    this.down('agreementstree').selectPath(path);
                    this.getEl().unmask();
                };
            this.openProjectAgreement(setPath);
            return false;
    },

    /**
     * ProjectContacts grid double click handler
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    onContactDblClick: function(view, rec) {
        var id = rec.get('contactid'),
            name = rec.get('name').split(' -> ').pop(), //need to split nested fullnames
            type = rec.get('type'),
            record = {
                getId: function() {return id;},
                getContactName: function() {return name;}
            };

            this.getController('contact.Contact').openContact(type, record);
            return false;
    },

    /*
     * ProjectAgreements grid click handler.
     * Expands the node on single click.
     * @param {Ext.view.View} view The grid view
     * @param {Ext.data.Model} rec The record for the clicked row
     */
    /*onProjectAgreementsClick: function(view, rec, el, idx, e) {
        var isExpanded = rec.isExpanded();

        //If the node is expandable and it is currently expanded then collapse otherwise expand
        if(!rec.collapsing && rec.isExpanded()) {
            rec.collapse();
        }else if(!rec.isExpanded()) {
            rec.expand();
        }
    },*/

    /**
     * Open the project window
     * @param {function} path The function that returns the path
     * to expand in the {@link PTS.view.project.window.AgreementsTree AgreementsTree}.
     * The function scope is the {@link PTS.view.project.window.Window ProjectWindow}.
     */
    openProjectAgreement: function(setPath) {
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
        //set the getProjectCode method, if it doesn't exist
        //we assume that the record contains the projectcode
        /*if(rec.getProjectCode === undefined) {
            rec.getProjectCode = function() {
                return rec.get('projectcode');
            };
        }*/

        this.getController('project.Project').openProject(this.projectRecord, callBack);
    }
});
