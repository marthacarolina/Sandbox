({
    loadRRinfo : function(cmp) {
        // Load related campaign(volunteer) and related jobs and shifts
        var action = cmp.get("c.getRelatedRecords");
        action.setParams({ "cloneId" : cmp.get("v.recordId")})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.relatedRecords", response.getReturnValue());
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
                    "message": " Something has gone wrong. in helper, loadRRInfo"
                });
            }
            toastEvent.fire();
        });
        $A.enqueueAction(action);        
    },
    
    saveClones : function(cmp) {
        var stStartDate = cmp.get("v.cloneStartDate");
        var stEndDate = cmp.get("v.cloneEndDate");
        //call the apex controller function to save the new clones
        //the non-string variables need to be typecasted as strings to pass through
        var action = cmp.get("c.cloneCampaign");
        action.setParams({ "campId" : cmp.get("v.relatedRecords.camp.Id"),
                          "campName" : cmp.get("v.cloneCampaignName"),
                          "campStartDate" :  JSON.stringify(stStartDate),
                          "campEndDate" : JSON.stringify(stEndDate),
                          "jobName" : cmp.get("v.cloneJobName")
                         })
        action.setCallback(this, function(response) {
            var state = response.getState();
                
            if(state === "SUCCESS") {
                //the result is the ID of the campaign cloned set that value
                //in the variable newCloneCampaign
                cmp.set("v.newClonedCampaign", response.getReturnValue());
                // Prepare a toast UI message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Clones Saved",
                    "message": "The new campaign was created."
                });
                
                // Update the UI: close panel, show toast, refresh account page
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                //prepare the navigation to the new record
                var navLink = cmp.find("navLink");

                var pageRef = {
                    type: "standard__recordPage",
                    attributes: {
                        actionName: "view",
                        objectApiName: "Campaign",
                        recordId : cmp.get("v.newClonedCampaign")
                    }
                };
                //navigate to new record
                navLink.navigate(pageRef);
            }
            else if (state === "ERROR") {
                console.log('Problem saving campaign, response state: ' + state);
            }
            else {
                console.log('Unknown problem, response state: ' + state);
            }
        });
        $A.enqueueAction(action);   
    },
    
})