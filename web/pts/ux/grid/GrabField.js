/**
* @class Ext.ux.grid.GrabField
* @extends Object
* Plugin for PagingToolbar which adds button for showing the contents of a
* field. The contents from each field are concatenated using a delimiter.
* @constructor
* @param {Object} config Configuration options
*/
Ext.define('Ext.ux.grid.GrabField', {
    extend: 'Ext.AbstractPlugin',
    requires: [
        'Ext.button.Button'
    ],

    /**
     * @cfg {String} text
     *
     * Text for the button.
     */

    /**
     * @cfg {String} iconCls
     *
     * Icon for the button.
     */

    /**
     * @cfg {String} tooltip
     *
     * Tooltip for the button.
     */

    /**
     * @cfg {String} delimiter
     *
     * Delimiter for the concatenation.
     */
    delimiter: ', \n',


    /**
     * @cfg {String} windowTitle
     *
     * Title for the message window.
     */
    windowTitle: 'Data',

    /**
     * @cfg {String} field
     *
     * Dataindex of field to concatenate.
     */

    constructor : function(config) {

        if (config) {
            Ext.apply(this, config);
        }

        this.callParent(arguments);
    },

    init : function(pbar){
        var me = this,
            idx = pbar.items.indexOf(pbar.child("#refresh")),
            btn;

        btn = Ext.create('Ext.button.Button', {
            text: me.text,
            iconCls: me.iconCls,
            tooltip: me.tooltip,
            scope: me,
            handler : function(btn){
                var grid = btn.up('gridpanel'),
                    store = grid.getStore(),
                    data = [],
                    gf = this;

                    if(gf.dataindex) {
                        store.each(function(r){
                                data.push(r.get(gf.dataindex));
                            },
                            gf
                        );

                        Ext.Msg.show({
                            title: gf.windowTitle,
                            //msg: 'Please enter your address:',
                            value: data.join(gf.delimiter),
                            width: 400,
                            defaultTextHeight: 300,
                            buttons: Ext.Msg.OK,
                            multiline: true,
                            animateTarget: btn,
                            icon: Ext.window.MessageBox.INFO
                        });

                    } else {
                        Ext.Error.raise('Ext.ux.grid.GrabField: No dataindex specified.');
                    }
console.info((gf.delimiter));

            }
        });

        pbar.insert(idx + 1, btn);

        //set the status of the button
        pbar.on('change', function(pbar, data) {
            btn.setDisabled(!data.total);
        });

    }
});
