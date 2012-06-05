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
        'Ext.ux.grid.Printer',
        'Ext.Date'
    ],

    /**
     * @cfg {String} text
     *
     * Text for the print button.
     */
    text: null,

    /**
     * @cfg {String} title
     *
     * Title for the print page. If null will print the
     * grid title and date.
     */
    title: null,

    constructor : function(config) {
        if (config) {
            Ext.apply(this, config);
        }
    },

    init : function(pbar){
        var idx = pbar.items.indexOf(pbar.child("#refresh")),
            print;

        print = Ext.create('Ext.button.Button', {
            text: this.text,
            mainTitle: this.title,
            iconCls: 'pts-printer',
            tooltip: 'Print the visible records',
            handler : function(){
                var grid = this.up('gridpanel'),
                    pageData = this.up('pagingtoolbar').getPageData(),
                    date = Ext.Date.format(new Date(), 'F j, Y, g:i a'),
                    right = 'Page ' + pageData.currentPage + ' of ' + pageData.pageCount,
                    title = this.mainTitle ? this.mainTitle : grid.title + ' - ' + date;

                Ext.ux.grid.Printer.mainTitle = title;
                Ext.ux.grid.Printer.rightTitle = right;
                Ext.ux.grid.Printer.print(grid);
            }
        });

        pbar.insert(idx + 1, print);

        //set the status of the button
        pbar.on('change', function(pbar, data) {
            print.setDisabled(!data.total);
        });

    }
});
