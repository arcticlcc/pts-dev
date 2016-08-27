/**
 * Controller for MainToolbar
 */
Ext.define('PTS.controller.MainToolbar', {
    extend: 'Ext.app.Controller',
    views: [
        'MainToolbar',
        'config.Window',
        'issue.Window'
    ],
    refs: [{
        ref: 'configForm',
        selector: 'configwindow form'
    }, {
        ref: 'issueForm',
        selector: 'issuewindow form'
    }],
    init: function() {
        this.control({
            'maintoolbar #userBtn': {
                beforerender: this.onBeforeShowUserBtn
            },
            'maintoolbar #switchPTS menu': {
                click: this.onClickSwitchPTS
            },
            'maintoolbar #issueBtn': {
                click: this.showIssue
            },
            'maintoolbar #configBtn': {
                click: this.showSettings
            },
            'configwindow button[action=close]': {
                click: this.closeSettings
            },
            'configwindow tool[action=close]': {
                click: this.closeSettings
            },
            'configwindow button[action=save]': {
                click: this.saveSettings
            },
            'issuewindow button[action=save]': {
                click: this.saveIssue
            }
        });
    },

    /**
     * Set user name. Add switch PTS options.
     */
    onBeforeShowUserBtn: function(btn) {
        var txt = PTS.user.getUserName(),
            menu = btn.menu.down('#switchPTS').menu,
            curr;

        btn.setText(txt);

        menu.add(PTS.UserId.paths);
        curr = menu.down('menuitem[url=' + window.location.pathname + ']');

        if (curr) {
            curr.disable();
        }
    },

    /**
     * Handle clicks on switchPTS button.
     */
    onClickSwitchPTS: function(menu, item) {
        this.switchPTS(item.url);
    },

    /**
     * Switch PTS by setting window location.
     */
    switchPTS: function(location) {
        window.location.href = location;
    },

    /**
     * Open issue window.
     */
    showIssue: function(btn) {
        var issueWindow = Ext.create('PTS.view.issue.Window');

        issueWindow.show();
    },

    /**
     * Open settings window.
     */
    showSettings: function(btn) {
        if (PTS.userConfigWindow === undefined) {
            PTS.userConfigWindow = Ext.create('PTS.view.config.Window');
        }

        PTS.userConfigWindow.show();
    },

    /**
     * Close settings window.
     */
    closeSettings: function(btn) {
        var form = this.getConfigForm().getForm();

        if (form.isDirty()) {
            form.reset();
        }
        btn.up('configwindow').close();
    },

    /**
     * Save settings record.
     */
    saveSettings: function(btn) {
        var form = this.getConfigForm().getForm(),
            el = this.getConfigForm().getEl(),
            record = form.getRecord();

        el.mask('Saving...');
        form.updateRecord(record);
        record.save({
            success: function(model, op) {
                var form = this.getConfigForm();

                form.loadRecord(model); //load the model to get desired trackresetonload behaviour
                el.unmask();
            },
            failure: function(model, op) {
                el.unmask();
            },
            scope: this //need the controller to load the model on success
        });
    },

    /**
     * Save issue.
     */
    saveIssue: function(btn) {
        var win = this.getIssueForm().up('window'),
            form = this.getIssueForm().getForm(),
            el = this.getIssueForm().getEl();

        el.mask('Saving...');
        if (form.isValid()) {
            form.submit({
              method:'POST',
              headers: {
                  'Content-Type': 'application/json;charset=utf-8'
              },
              jsonData: Ext.JSON.encode(form.getFieldValues()),
              //waitTitle:'Connecting',
              //waitMsg:'Creating...',
                success: function(form, action) {
                  el.unmask();
                  win.close();
                   //Ext.Msg.alert('Success', action.result.msg);
                   //
                   Ext.create('widget.uxNotification', {
                       title: 'Issue Created',
                       iconCls: 'ux-notification-icon-information',
                       html: 'Issue was created.'
                   }).show();
                },
                failure: function(form, action) {
                  el.unmask();
                    //Ext.Msg.alert('Failed', action.result.msg);
                }
            });
        }
    },

    /**
     * Reset settings form.
     */
    resetSettings: function() {
        var form = this.getConfigForm().getForm();

        form.reset();
    }
});
