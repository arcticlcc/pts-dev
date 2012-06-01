/**
* @class Ext.ux.PrintGrid
* @extends Object
* Plugin for PagingToolbar which adds button for printing the grid
* @constructor
* @param {Object} config Configuration options
*/
Ext.define('Ext.ux.grid.PrintGrid', {
    extend: 'Object',
    requires: [
        'Ext.button.Button',
        'Ext.ux.grid.Printer'
    ],

    constructor : function(config) {
        if (config) {
            Ext.apply(this, config);
        }
    },

    init : function(pbar){
        var idx = pbar.items.indexOf(pbar.child("#refresh")),
            print;

        print = Ext.create('Ext.button.Button', {
            text: 'Print',
            iconCls: 'pts-printer',
            handler : function(){
                Ext.ux.grid.Printer.print(this.up('gridpanel'));
            }
        });

        pbar.insert(idx + 1, print);

    }
});
