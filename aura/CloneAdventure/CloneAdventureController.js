({
    doInit : function(component, event, helper) {
        // Retrieve the information from the related records 
        helper.loadRRinfo(component);
    },
    
    handleSaveClones : function(component, event, helper) {
        // Save clones with new name, startDate & endDate
         // get the 'dateValidationError' attribute value
        var isDateError = component.get("v.dateValidationError");        
        if(isDateError != true){
            helper.saveClones(component);
        }
    },
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    validateDate : function(component, event, helper) {
        if (component.get("v.cloneStartDate") <= component.get("v.cloneEndDate")) {
           component.set("v.dateValidationError" , false);
        }else{
            component.set("v.dateValidationError" , true);
        }         
    },
})