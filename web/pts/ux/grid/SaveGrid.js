/**
* @class Ext.ux.grid.SaveGrid
* @extends Object
* Plugin for PagingToolbar which adds button for saving the grid
* @constructor
* @param {Object} config Configuration options
*/
Ext.define('Ext.ux.grid.SaveGrid', {
    extend: 'Object',
    requires: [
        'Ext.button.Button',
        'Ext.ux.grid.Save'
    ],

    /**
     * @cfg {String} text
     *
     * Text for the save button.
     */
    text: null,

    constructor : function(config) {
        if (config) {
            Ext.apply(this, config);
        }
    },

    init : function(pbar){
        var idx = pbar.items.indexOf(pbar.child("#refresh")),
            save;

        save = Ext.create('Ext.button.Button', {
            text: this.text,
            iconCls: 'pts-menu-savetable',
            tooltip: 'Download the grid',
            handler : function(){
                Ext.ux.grid.Save.save(this.up('gridpanel'));
            }
        });

        pbar.insert(idx + 1, save);

        //set the status of the button
        pbar.on('change', function(pbar, data) {
            save.setDisabled(!data.total);
        });
    }
});
