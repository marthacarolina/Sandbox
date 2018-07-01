({
    goToRecord : function(cmp, event, helper) {
        // Fire the event to navigate to the contact record
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": cmp.get("v.camp.Id")
        })
        sObjectEvent.fire();
    },
    handleSelect : function(cmp, event, helper){
        // handle the menu(record options) selection
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue === "edit"){
            helper.openModal(cmp);
        }
        else if (selectedMenuItemValue === "delete"){
            alert("user wants to delete the record")
        }
    },
    
    closeModal: function(cmp, event, helper) {
      // for Hide/Close Modal,set the "isEdit" attribute to "Fasle"  
      cmp.set("v.openEdit", false);
   },
   
})