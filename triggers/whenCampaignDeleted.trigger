trigger whenCampaignDeleted on Campaign (before delete) {
	List<Campaign> delCampaign = trigger.old;
    Boolean dontDelete = False;
    Boolean relCampaign = False;
    for (Campaign eachCampaign : delCampaign)
    {
        //If the campaign is Adventure type check to see if there are campaign members
        //with status "Attended" and if there is a related campaign: volunteer campaign
        If (eachCampaign.RecordTypeId == '012o0000000xwhO')
        {
       		If (eachCampaign.Related_Campaign__c != NULL)
 				relCampaign = True;     
    		List<CampaignMember> cMs = [SELECT id, status FROM CampaignMember
                               WHERE CampaignId = :eachCampaign.Id];
 
    		For (CampaignMember eachCM : cMS)
		    {
		     	If (eachCM.Status == 'Attended')
                {dontDelete = True;}
		    }
			If (dontDelete)
				eachCampaign.adderror('Cannot delete a campaign that has members with status Attended. Their status must be changed first.');
			If (relCampaign)
                eachCampaign.adderror('Before deleting the campaign you must delete the volunteer campaign associated with it.');
    	}
        Else 
        //If the campaign is a volunteer campaign then retreive the Adventure campaign related to it
        //and delete the related campaign from the Adventure record
        If (eachCampaign.RecordTypeId == '012o0000001AJaa')
        {
            if (eachCampaign.Related_Campaign__c != NULL)
            {
                Campaign relCampRecord = [SELECT ID, Related_Campaign__c FROM Campaign 
                                         WHERE Id = :eachCampaign.Related_Campaign__c];
                relCampRecord.Related_Campaign__c = NULL;
                Update relCampRecord;
            }
        }
    }
}