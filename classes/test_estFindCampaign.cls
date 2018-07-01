@isTest
public class test_estFindCampaign {
    private static testMethod void tstestFindCampaign(){
        TestDataFactory.CreateGAU('Activity Fees');
        Id fundCamp = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Fundraising').getRecordTypeId();
        Campaign camp = new Campaign(name = 'AZGives Day 2017',
                                     StartDate = date.today(),
                                     EndDate = date.today(),
                                     Status = 'In Progress',
                                     Type = 'Fundraising',
                                     RecordTypeId = fundCamp);
        insert camp;
        camp = new Campaign();        
        ApexPages.StandardController std = 
            new ApexPages.StandardController(camp);
        extFindCampaign sce = new extFindCampaign(std);
        system.assertEquals(date.today(),sce.campaign.startdate);        
    }
}