/**
 * Controller for Modification Form
 */
Ext.define('PTS.controller.project.form.ModificationForm', {
    extend: 'PTS.controller.project.form.BaseModificationForm',

    views: [
        'project.form.AgreementForm',
        'project.form.ModificationForm'
    ],
    models: [
        'PurchaseRequest',
        'Status',
        'ModStatus'
    ],
    stores: [
        'PurchaseRequests',
        'Statuses',
        'ModStatuses'
    ],
    refs: [{
        ref: 'agreementForm',
        selector: 'modificationform#itemCard-60 #itemForm'
    },{
        ref: 'agreementCard',
        selector: 'modificationform#itemCard-60'
    }],

    init: function() {
        this.control({
            'modificationform#itemCard-60 roweditgrid': {
                edit: this.onDetailRowEdit,
                activate: this.onDetailActivate
            },
            'agreementform#itemCard-60 #statusGrid': {
                validateedit: this.validateStatus
            },
            'agreementform#itemCard-60 textfield[name=modcode]': {
                change: this.onChangeCode
            },
            'agreementform#itemCard-60 textfield[name=modificationcode]': {
                change: this.onChangeParentCode
            }
        });

        // We listen for the application-wide loaditem event
        this.application.on({
            itemload: this.onItemLoad,
            newitem: this.onNewItem,
            scope: this
        });

    },
        
    /**
     * Update the modificationcode.
     */
    onChangeCode: function(field) {
        var form = field.up('form').getForm(),
            rec =  form.getRecord(),
            val = form.findField('modcode').getValue(),
            del = form.findField('codedelimiter').getValue(),
            code = rec.get('parentcode') + del + val;
            
        form.findField('modificationcode').setRawValue(code);      
    },
    
    /**
     * Update the modcode, should only fire on inital load.
     */
    onChangeParentCode: function(field) {
        var form = field.up('form').getForm(),
            modcode =  form.findField('modcode'),
            del = form.findField('codedelimiter').getValue(),            
            val = field.getValue().split(del),
            code = val[1] ? val[1] : val[0];
        
        if(code !== null) {    
            modcode.originalValue = code;    
            modcode.setValue(code);
        }        
    }
});
