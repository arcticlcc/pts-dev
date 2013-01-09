/**
* @class Ext.ux.grid.PrintGrid
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
     * @cfg {String/Function} title
     *
     * Title for the print page. If null will print the
     * grid title.
     *
     * If the title option is specified as a function, then the function will be called using the PagingToolbar as the
     * scope (`this` reference). Any resulting string from that call is then used as the title.
     */
    title: null,

    /**
     * @property printHidden
     * @type Boolean
     * True to always print hidden columns
     */
    printHidden: false,

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
            printHidden: this.printHidden,
            iconCls: 'pts-printer',
            itemId: 'printBtn',
            tooltip: 'Print the visible records',
            handler : function(){
                var me = this,
                    grid = me.up('gridpanel'),
                    pageData = me.up('pagingtoolbar').getPageData(),
                    date = Ext.Date.format(new Date(), 'F j, Y, g:i a'),
                    right = 'Page ' + pageData.currentPage + ' of ' + pageData.pageCount,
                    title;

                if (Ext.isFunction(me.mainTitle)) {
                    title = me.mainTitle.call(pbar);
                }else {
                    title = me.mainTitle ? me.mainTitle : grid.title + ' - ' + date;
                }

                Ext.ux.grid.Printer.mainTitle = title;
                Ext.ux.grid.Printer.rightTitle = right;
                Ext.ux.grid.Printer.printHidden = me.printHidden;
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
