({
    doInit : function(component, event, helper) {
        // Retrieve campaigns during component initialization
        helper.loadCMinfo(component);
    },
    
    handleSelect : function(component, event, helper) {
        var allCampaigns = component.get("v.allCampaigns");        

        //Get the selected option: "Adventure", "Fundraising", "Volunteer" or "All"
        var selected = event.getSource().get("v.value");
    
        var filter = [];
        var k = 0;
        for (var i=0; i<allCampaigns.length; i++){
            var c = allCampaigns[i];
            if (selected != "All"){
                if(c.RecordTypeId == selected) {
                    filter[k] = c;
                    k++; 
                }
            }
            else {
                   filter = allCampaigns;
            }       
        }
        //Set the filtered list of campaigns based on the selected option
        component.set("v.campaignList", filter);
        helper.updateTotal(component);
    }
})