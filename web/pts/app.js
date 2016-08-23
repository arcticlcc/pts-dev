/**
 * @class PTS.app
 * @author Josh Bradley <joshua_bradley@fws.gov>
 * The PTS application bootstrap file
 *
 * **TODO**:
 *
 * - Document application level events
 */

Ext.Loader.setConfig({
    enabled: true,
    paths: {
        'Extensible': './lib/extensible/src',
        'Extensible.example': './lib/extensible/examples',
        'Ext.ux': './ux',
        'GeoExt': './lib/geoext/src/GeoExt'
    },
    disableCaching: true
});

Ext.application({
    requires: [
        'PTS.Defaults',
        'PTS.model.User', //not requesting with just models config
        'PTS.util.DataTypes', //custom datatypes/
        'PTS.util.VTypes', //custom validation types/
        'PTS.Overrides',
        'PTS.util.ActivityMonitor',
        'PTS.util.AssociationJsonWriter', //custom writer
        'Ext.ux.window.Notification'
    ],
    name: 'PTS',
    version: '0.19.1',

    appFolder: 'app',
    autoCreateViewport: false,
    enableQuickTips: true,

    models: ['User', 'UserConfig'],
    stores: ['States', 'Countries', 'Positions', 'ProjectIDs', 'ProductGroupIDs'],
    controllers: [
        'Main',
        'MainToolbar',
        'dashboard.Dashboard',
        'project.Project',
        'product.Product',
        'contact.Contact',
        'report.Report',
        'tps.Tps'

    ],

    /**
     * @event newitem
     * Fired when a new {@link Ext.data.Model#phantom phantom} model is loaded into
     * an {@link PTS.view.project.window.ItemDetail ItemDetail} form.
     * @param {Ext.data.Model} model The Model instance that was loaded into the form
     * @param {Ext.form.Panel} form The form panel for the item, use ownerCt to get the card
     */

    /**
     * @event savedeliverable
     */

    /**
     * @event syncprojectcontacts
     */

    /**
     * Store the last application error.
     * @param {String} txt The error string.
     */
    setError: function(txt) {
        this.lastError = txt;
    },

    /**
     * Retrieve the last application error.
     * @return {String} The last recorded error.
     */
    getError: function(full) {
        var error = this.lastError;

        return (full || (error.length < 300)) ? error : error.substr(0, 300) + '...';
    },

    /**
     * Creates an error notification.
     * @param {String} txt The error string.
     */
    showError: function(txt) {
        Ext.create('widget.uxNotification', {
            title: 'Error',
            iconCls: 'ux-notification-icon-error',
            html: txt
        }).show();
    },

    /**
     * Launch the application.
     */
    launch: function() {
        //Use Notifications for Ext errors
        Ext.Error.handle = function(err) {
            PTS.app.showError(err.msg);
        };

        Ext.Ajax.defaultHeaders = {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        };

        //Handle Ajax exceptions globally
        //TODO: Make Ajax exception handling better, remove redundant code
        Ext.Ajax.on('requestexception', function(conn, response, op) {
            var txt = Ext.JSON.decode(response.responseText);

            //don't do anything for canceled requests
            if (!response.aborted && txt) {
                //set the global app error
                PTS.app.setError(txt.message);

                //only fire the global handler if no failure handler is passed
                //we have to check for regular ajax and data operation callbacks
                if (undefined === op.failure && (undefined === op.operation || undefined === op.operation.failure)) {
                    /*Ext.MessageBox.show({
                       title: 'Error',
                       msg: txt.message,
                       buttons: Ext.MessageBox.OK,
                       //animateTarget: 'mb9',
                       //fn: showResult,
                       icon: Ext.Msg.ERROR
                   });*/
                    Ext.create('widget.uxNotification', {
                        title: 'Error',
                        iconCls: 'ux-notification-icon-error',
                        html: txt.message
                    }).show();
                }
            }
        });

        //add a reference to the app
        PTS.app = this;
    }
});
