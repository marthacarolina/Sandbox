public class CloneAdventureApexController {
    @AuraEnabled
    public static RelRecords getRelatedRecords(id cloneId){
        system.debug('cloneID = ' + cloneId);
        boolean noVol = false;
        RelRecords RR = new RelRecords(); // records to clone
        id volRecType = 
            Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Volunteer Campaign').getRecordTypeId();
        RR.camp = [SELECT id, Name, StartDate, EndDate, 
                   Related_Campaign__c, Type, 
                   RecordTypeId, Description,
                   Fee_for_Activity__c, IsActive,
                   Contract_Reservation_Fee__c
                   FROM Campaign
                   WHERE id = :cloneId];       
        // if the campaign is not a volunteer campaign, get the related campaign = volunteer campaign
        If (RR.camp.RecordTypeId != volRecType){
            if (RR.camp.Related_Campaign__c != null)
            {                
                RR.RelatedCampaign = [SELECT id, Name, StartDate, EndDate, 
                                      Related_Campaign__c, Type, 
                                      RecordTypeId, Description,
                                      Fee_for_Activity__c, IsActive,
                                      Contract_Reservation_Fee__c
                                      FROM Campaign
                                      WHERE id = :RR.camp.Related_Campaign__c];
                Map<id,GW_Volunteers__Volunteer_Job__c> MapVolJobs = 
                    new Map<id,GW_Volunteers__Volunteer_Job__c>(
                        [SELECT id, Name, 
                         GW_Volunteers__Location_City__c,
                         GW_Volunteers__Location_Information__c,
                         GW_Volunteers__Location__c, 
                         GW_Volunteers__Location_Street__c,
                         GW_Volunteers__Location_Zip_Postal_Code__c,
                         GW_Volunteers__Display_on_Website__c
                         from GW_Volunteers__Volunteer_Job__c
                         WHERE GW_Volunteers__Campaign__c = :RR.RelatedCampaign.id]);
                RR.VolJobs = new List<GW_Volunteers__Volunteer_Job__c>();
                if (MapVolJobs.values().size() > 0) {
                    RR.VolJobs = MapVolJobs.values();
                }  
                RR.VolShifts = [SELECT id, GW_Volunteers__Volunteer_Job__c, 
                                GW_Volunteers__Description__c,
                                GW_Volunteers__Desired_Number_of_Volunteers__c,
                                GW_Volunteers__Duration__c,
                                GW_Volunteers__Start_Date_Time__c
                                from GW_Volunteers__Volunteer_Shift__c
                                WHERE GW_Volunteers__Volunteer_Job__c IN :MapVolJobs.keySet()];
            }
            else
            {
                noVol = true;
            }                        
        }
        return RR; //return the campaign to be cloned as well as all the related records         
    }
    
    @AuraEnabled
    public static id cloneCampaign(String campId, String campName, String campStartDate,
                                  String campEndDate)
    {
        id cloneID1 = (id) campId;
        if (campStartDate.length() > 10){
            campStartDate = campStartDate.substring(1,11);
            campEndDate = campEndDate.substring(1,11);
        }
        //system.debug('campStartDate = ' + campStartDate);
        //system.debug('campEndDate = ' + campEndDate);
        date dateStartDate = date.valueOf(campStartDate); 
        date dateEndDate = date.valueOf(campEndDate);       
        
        id volunteer = 
            Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Volunteer Campaign').getRecordTypeId(); 
        id adventure = 
            Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Adventure').getRecordTypeId(); 
            
        //retrieve all the records to clone using getRelatedRecords method
        RelRecords campaignToClone = getRelatedRecords(cloneID1);
        //declare the variable that will hold the clones (copies)
        RelRecords copies;
        boolean isVolunteer = campaignToClone.camp.RecordTypeId == volunteer;
        if (!isVolunteer) 
        {
            //if the campaign to clone is not a volunteer campaign
            copies = new RelRecords(); //instantiate the new clones
            //clone the campaign that initiated this procedure
            copies.camp = campaignToClone.camp.clone(false, true, false, false);
            //change the name, start time and end time of the copy
            copies.camp.Name = campName;
            copies.camp.StartDate = dateStartDate;
            copies.camp.EndDate = dateEndDate;
            // insert the campaign to get an id 
            // *** when a campaign of recordtype Adventure is inserted, the campaign
            // trigger will also make the volunteer campaign.                                    
            insert copies.camp;
            id newVolunteerCampaign;
            //check that there is a volunteer related campaign
            if (campaignToClone.RelatedCampaign != null){
                    //clone the volunteer campaign and change the fields to the new values
                if (copies.camp.RecordTypeId != adventure) {
                    copies.RelatedCampaign = campaignToClone.RelatedCampaign.clone(false, true, false, false);
                    copies.RelatedCampaign.Related_Campaign__c = copies.camp.id;
                    copies.RelatedCampaign.Name = 'Volunteer ' + copies.camp.Name;
                    copies.RelatedCampaign.StartDate = dateStartDate;
                    copies.RelatedCampaign.EndDate = dateEndDate;
                    //insert the new Volunteer Campaign record to get an id
                    insert copies.RelatedCampaign;
                    newVolunteerCampaign = copies.RelatedCampaign.id;
                    copies.camp.Related_Campaign__c = copies.RelatedCampaign.id;
                    //update the campaign
                    update copies.camp;               
                }
                else {
                    // the volunteer campaign has already been created by the trigger
                    // retrieve the id of the volunteer campaign that was created
                    Campaign tempCamp = [SELECT id, Related_Campaign__c
                                        FROM Campaign
                                        WHERE id = :copies.camp.id];
                    //set the id of the new volunteer campaign to use for creating jobs
                    newVolunteerCampaign = tempCamp.Related_Campaign__c;
                }
                //if there are jobs for the volunteer campaign, clone them
                copies.VolJobs = new List<GW_Volunteers__Volunteer_Job__c>();            
                for (GW_Volunteers__Volunteer_Job__c job : campaignToClone.VolJobs) {
                    GW_Volunteers__Volunteer_Job__c oneJob =
                        job.clone(false,true,false,false);
                    oneJob.GW_Volunteers__Campaign__c = newVolunteerCampaign;
                    insert oneJob;
                    copies.VolJobs.add(oneJob);
                    for (GW_Volunteers__Volunteer_Shift__c shift : campaignToClone.VolShifts) {
                        //copy all the shifts that belong to this Job
                        if (shift.GW_Volunteers__Volunteer_Job__c == job.id){
                            GW_Volunteers__Volunteer_Shift__c oneShift = 
                                shift.clone(false,true,false,false);
                            //change the job id to the new job copy id
                            oneShift.GW_Volunteers__Volunteer_Job__c = oneJob.id;
                            //change the date of the shift, but keep the same time
                            time startTime = oneShift.GW_Volunteers__Start_Date_Time__c.Time();
                            oneShift.GW_Volunteers__Start_Date_Time__c = DateTime.newInstance(dateStartDate, startTime);
                            copies.VolShifts.add(oneShift);
                        }
                    }
                }
                insert copies.VolShifts;
            }
        }
        //return the id of the campaign clone
        system.debug('copies.camp.id = '+ copies.camp.id);
        return copies.camp.id;
    }
}