global with sharing class ContactAdventureController {
@AuraEnabled
    Public static List<CampInvolvment> getAdventures(ID partId) {
        List<CampaignMember> involvedIn = [Select id, status, campaignId,
                                           Activity_Days__c
                                           from CampaignMember
                                           WHERE ContactId = :partId 
                                           ORDER BY CampaignDate__c];
        Map<id, CampaignMember> campMems = new Map<id, CampaignMember>();
        for (CampaignMember cm: involvedIn)
            campMems.put(cm.CampaignId, cm);
        List<Campaign> Adventures = [SELECT id, Name, StartDate, EndDate, 
                                     Type, RecordTypeId 
                                     FROM Campaign 
                                     WHERE id IN :campMems.keySet()];
        List<CampInvolvment> cInvolved = new List<CampInvolvment>();
        integer x = 0;
        for (Campaign c : Adventures){
            CampInvolvment cInv = new CampInvolvment();
            cInv.Id = c.Id;
            cInv.Name = c.Name;
            cInv.StartDate = c.StartDate;
            cInv.EndDate = c.EndDate;
            cInv.Type = c.Type;
            cInv.RecordTypeId = c.RecordTypeId;
            cInv.Status = campMems.get(c.id).Status;
            cInv.AdventureDays = (Integer) campMems.get(c.id).Activity_Days__c;
            cInv.CMid = campMems.get(c.id).id;
            cInvolved.add(cInv);
        }
        return cInvolved;        
    }
    
    @AuraEnabled
    public static List<String> getCRecTypeIds(){
        List<String> theIds = new List<String>();
        string advId = 
            (string) Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Adventure').getRecordTypeId();  
        theIds.add(advId);
        string fundId = 
            (string) Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Fundraising').getRecordTypeId();
        theIds.add(fundId);
        string volId = 
            (string) Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Volunteer Campaign').getRecordTypeId();
        theIds.add(volId);
        return theIds;
    }    
}