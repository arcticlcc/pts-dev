/**
 * @class PTS.data.Calendar
 * PTS calendar definition
 *
 * - **C1** : Past Due
 * - **C2** : Due Immediately
 * - **C3** : Due Soon
 * - **C4** : Completed
 */
Ext.define('PTS.data.Calendar', {
    constructor: function() {
        return {
            "calendars":[{
                "id": 1,
                "title": "Past Due",
                "color": 2
            },{
                "id": 2,
                "title": "Due Immediately",
                "color": 6
            },{
                "id": 3,
                "title": "Due Soon",
                "color": 20
            },{
                "id": 4,
                "title": "Completed",
                "color": 26
            }]
        };
    }
});
