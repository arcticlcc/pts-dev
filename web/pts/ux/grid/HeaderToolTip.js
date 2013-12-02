/**
 * @class Ext.ux.grid.HeaderToolTip
 * @namespace Ext.ux.grid
 *
 *  Text tooltips should be stored in the grid column definition
 */
Ext.define('Ext.ux.grid.HeaderToolTip', {
    alias: 'plugin.headertooltip',

    init: function(grid) {
        var headerCt = grid.headerCt;

        headerCt.on("afterrender", this.createTip, grid);
    },

    createTip: function() {
        var grid = this,
            headerCt = grid.headerCt;

        grid.tip = Ext.create('Ext.tip.ToolTip', {
            target: headerCt.el,
            delegate: ".x-column-header",
            trackMouse: true,
            renderTo: Ext.getBody(),
            listeners: {
                beforeshow: function(tip) {
                    var c = headerCt.down('gridcolumn[id=' + tip.triggerElement.id + ']');

                    if (c) {
                        tip.update(c.tooltip /*|| c.text*/);
                        return true;
                    }

                    return false;
                }
            }
        });
    }
});
