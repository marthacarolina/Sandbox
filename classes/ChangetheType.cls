public class ChangetheType {
    public static void ChangeTypeforMC() {
        id fundId = 
            Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Fundraising').getRecordTypeId();
        id advId = 
            Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Adventure').getRecordTypeId();

        List<Campaign> ListOfCampaigns = [SELECT id, Name, RecordTypeId FROM Campaign
                                          WHERE RecordType.DeveloperName = 'Adventure'];
        for (Campaign each : ListOfCampaigns)
        {
            if (each.Name.contains('MailChimp'))
                each.RecordTypeId = fundId;            
        }
        Database.SaveResult[] srList = Database.update(ListOfCampaigns, false);
    }
}