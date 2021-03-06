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
    }, {
        ref: 'projectDetail',
        selector: 'projecttab projectdetail'
    }],

    init: function() {

        this.control({
            'projectdetail > #projectAgreements': {
                beforeitemdblclick: this.onProjectAgreementsDblClick,
                load: this.onProjectAgreementsLoad //,
                    //itemclick: this.onProjectAgreementsClick
            },
            'projectdetail > deliverablelist': {
                itemdblclick: this.onDeliverableDblClick
            },
            'projectdetail > #projectContacts': {
                itemdblclick: this.onContactDblClick
            },
            'projectdetail > deliverablelist #printBtn': {
                click: this.onDelPrintBtnClick
            },
            'projectdetail > #projectContacts #printBtn': {
                click: this.onContactPrintBtnClick
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
            grids = detail.query('treepanel, grid'),
            store = detail.getActiveTab().getStore();

        Ext.each(grids, function(grid) {
            grid.getStore().setProxy({
                type: 'ajax',
                url: PTS.baseURL + '/project/' + id + '/' + grid.uri,
                reader: {
                    type: 'json',
                    root: grid.isXType('grid') ? 'data' : ''
                }
            });
        });

        //hack to prevent rendering error when switching projects
        //before initial request returns
        if (store.loading && store.lastOperation) {
            var requests = Ext.Ajax.requests,
                rid;

            for (rid in requests) {
                if (requests.hasOwnProperty(rid) && requests[rid].options === store.lastOperation.request) {
                    Ext.Ajax.abort(requests[rid]);
                }
            }
        }


        store.on('beforeload', function(store, operation) {
            store.lastOperation = operation;
        }, this, {
            single: true
        });

        //load the store
        store.load();

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
    onDelPrintBtnClick: function(btn) {
        var code = this.projectRecord.get('projectcode');

        btn.mainTitle = function() {
            return this.child('cycle#filter').getActiveItem().text + ' Deliverables for ' + code;
        };
    },

    /**
     * Updates ProjectContacts grid print title.
     * @param {Ext.Component} btn
     */
    onContactPrintBtnClick: function(btn) {
        var code = this.projectRecord.get('projectcode');

        btn.mainTitle = function() {
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
     * ProjectAgreements grid load handler,
     * Expand the Agreements node
     * @param {Ext.data.Store} store The store
     * @param Ext.util.Grouper[] records
     * @param Boolean successful
     * @param Ext.data.Operation operation
     */
    onProjectAgreementsLoad: function(store, records, successful, operation) {
        if (successful) {
            this.getProjectAgreements().expandPath('/root/art-0');
        }
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
                var path = store.getNodeById("d-" + id + "-" + modid).getPath();
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
                getId: function() {
                    return id;
                },
                getContactName: function() {
                    return name;
                }
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

            if (store.getRootNode().hasChildNodes()) {
                setPath(store);
            } else {
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
