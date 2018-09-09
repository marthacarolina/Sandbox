public class VolApprovalController {
    public GW_Volunteers__Volunteer_Job__c job {get;set;}
    public GW_Volunteers__Volunteer_Shift__c shift {get;set;}
    public List<GW_Volunteers__Volunteer_Hours__c> volunteersInList {get;set;}
    public GW_Volunteers__Volunteer_Hours__c volToConfirm {get;set;}
    public Contact volunteer {get;set;}
    public campaign volCampaign {get;set;}

    public void VolApprovalController(){}
    
    public boolean getInit(){
        //retrieve the page parameters
        id campId = (id)ApexPages.currentPage().getParameters().get('id');
        id jobID =  (id)ApexPages.currentPage().getParameters().get('job');
        id shiftID = (id)ApexPages.currentPage().getParameters().get('shift');
        id volId = (id)ApexPages.currentPage().getParameters().get('vol');
        volCampaign = [SELECT id, Name, StartDate, EndDate, Description
                      FROM Campaign
                      WHERE Related_Campaign__c = :campId limit 1];
        job = [SELECT id, Name,
               GW_Volunteers__Description__c,
               GW_Volunteers__Display_on_Website__c,
               GW_Volunteers__Location__c,
               GW_Volunteers__Location_Street__c,
               GW_Volunteers__Location_City__c,
               GW_Volunteers__Location_Zip_Postal_Code__c,
               GW_Volunteers__Location_Information__c
               FROM GW_Volunteers__Volunteer_Job__c
               WHERE GW_Volunteers__Campaign__c = :volCampaign.id
               LIMIT 1];
        shift = [SELECT id, GW_Volunteers__Start_Date_Time__c, 
                 GW_Volunteers__Number_of_Volunteers_Still_Needed__c,
                 GW_Volunteers__Duration__c,
                 GW_Volunteers__Desired_Number_of_Volunteers__c,
                 GW_Volunteers__Total_Volunteers__c
                 FROM GW_Volunteers__Volunteer_Shift__c                
                 WHERE  GW_Volunteers__Volunteer_Job__c = :job.id];  
        List<GW_Volunteers__Volunteer_Hours__c> allVolunteers =
            [SELECT id, GW_Volunteers__Contact__c,
             GW_Volunteers__Full_Name__c,
             GW_Volunteers__Status__c
             FROM GW_Volunteers__Volunteer_Hours__c
             WHERE                            
             GW_Volunteers__Volunteer_Shift__c = :shift.Id AND
             GW_Volunteers__Volunteer_Job__c = :job.id];
        //get a list of the volunteers that haven't been confirmed yet - volToConfirm
        //and a list of the volunteers already confirmed - volunteersInList
        volunteersInList = new List<GW_Volunteers__Volunteer_Hours__c>();
        volToConfirm = new GW_Volunteers__Volunteer_Hours__c();
        for (GW_Volunteers__Volunteer_Hours__c allV : allVolunteers){
            if (allV.GW_Volunteers__Contact__c != volId){
                volunteersInList.add(allV);
            }
            else {
                volToConfirm = allV;
            }
        }
        return true;        
    }
    
    public PageReference Approve(){
        return null;
    }
}