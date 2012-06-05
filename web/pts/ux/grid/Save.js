/**
 * @class Ext.ux.grid.Save
 * @author Josh Bradley
 * Helper class to easily save the contents of a grid. Will open a new window with a link
 * to the download file.
 *
 * Usage:
 *
 * 1 - Add Ext.Require Before the Grid code
 * Ext.require([
 *   'Ext.ux.grid.Save',
 * ]);
 *
 * 2 - Declare the Grid
 * var grid = Ext.create('Ext.grid.Panel', {
 *   columns: //some column model,
 *   store   : //some store
 * });
 *
 * 3 - Save
 * Ext.ux.grid.Save.save(grid);
 *
 */
Ext.define("Ext.ux.grid.Save", {

    requires: [
        'Ext.data.Operation',
        'Ext.data.proxy.Rest',
        'Ext.window.MessageBox',
        'Ext.Ajax.request',
        'Ext.Template'
    ],

    statics: {
        /**
         * Saves the passed grid. Respects any {@link Ext.util.Filter) and
         * {@link Ext.util.Sorter) applied to the grid.
         */
        save: function(grid) {
            var store = grid.getStore(),
                progress = this.progress,
                dir = this.saveDir,
                op = new Ext.data.Operation({
                    action: 'read',
                    filters: store.filters.items,
                    sorters: store.sorters.items
                }),
                proxy = new Ext.data.proxy.Rest({
                    url: store.getProxy().url,
                    format: this.saveFormat
                }),
                //build request
                req = proxy.buildRequest(op);

                //show msg
                progress.show({
                    msg: 'Fetching your data, please wait...',
                    width:300,
                    wait:true,
                    waitConfig: {interval:200},
                    modal: false,
                    title: 'Retrieving Data...'
                    //icon:'ext-mb-download'
                });

                //send request
                Ext.Ajax.request({
                    url: req.url,
                    params: req.params,
                    method: 'GET',
                    success: function(response, opts) {
                        var obj = Ext.decode(response.responseText),
                            tpl = new Ext.Template(
                                '<div>',
                                    '<a href="{dir}/{file}">Click to Download</a> - {size}',
                                    '<br/>',
                                    '<span>This file link will be active for two weeks.</span>',
                                '</div>',
                                {
                                    compiled: true, // compile immediately
                                    disableMethods: true
                                }
                            );

                        progress.show({
                            msg: tpl.apply({
                                dir: dir,
                                file: obj.data.file,
                                size: obj.data.size
                            }),
                            width:300,
                            closable: true,
                            modal: false,
                            icon:'pts-icon-download',
                            title: 'Download'
                        });

                    },
                    failure: function(response, opts) {
                        var obj = Ext.decode(response.responseText);
                        progress.show({
                            msg: obj.message,
                            width:300,
                            closable: true,
                            buttons: Ext.Msg.OK,
                            icon: Ext.MessageBox.ERROR,
                            modal: false,
                            title: 'Error!'
                        });
                    }
                });
        },

        /**
         * @property saveFormat
         * @type String
         * The extension of the file type to return. Used to build the REST url.
         */
        saveFormat: 'csv',

        /**
         * @property saveDir
         * @type String
         * The directory where saved files are placed.
         */
        saveDir: 'dl',

        /**
         * @property progress
         * @type Ext.window.MessageBox
         * The progress window.
         */
        progress: Ext.create('Ext.window.MessageBox')
    }
});
