({
    loadCMinfo : function(cmp) {
        // Load all contact campaigns 
        var action = cmp.get("c.getAdventures");
        action.setParams({ "partId" : cmp.get("v.recordId")})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.allCampaigns", response.getReturnValue());
                cmp.set("v.campaignList", response.getReturnValue());
                this.updateTotal(cmp);
                this.loadCampRecTypes(cmp);
            }
            
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " Your campaigns have been loaded successfully."
                });
            }
            else {
                toastEvent.setParams({
                    "title": "Error!",
                    "message": " Something has gone wrong."
                });
            }
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },

    loadCampRecTypes : function(cmp) {
        // Load RecordtypeIds for object campaign
        var action = cmp.get("c.getCRecTypeIds");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.cRecTypeIds", response.getReturnValue());
            }
            
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " Your campaigns have been loaded successfully."
                });
            }
            else {
                toastEvent.setParams({
                    "title": "Error!",
                    "message": " Something has gone wrong."
                });
            }
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },    
    
    updateTotal: function(cmp) {
        var campaigns = cmp.get("v.campaignList");
        cmp.set("v.totalCampaigns", campaigns.length);
    },
})