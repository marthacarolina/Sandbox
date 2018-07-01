@isTest
public class printCampaignRosters_Test {
    @isTest(SeeAllData='true')
    private static void doTesting(){
        //generate records for test 
        //insert contacts that will become participants in the campaign      
        List<Contact> conts = TestDataFactory.CreateContacts(5, 0) ;  
        List<Contact> volunteers = TestDataFactory.CreateContacts(4, 5);
        //retrieve the fee for Cycling to use when creating campaign
        date cSDate = date.newInstance(2018, 1, 1);
        date cEDate = date.newInstance(2018, 1, 31);
        List<Campaign> camp_with_all = [SELECT id, Name, Related_Campaign__c,
                                  RecordTypeId 
                                  FROM Campaign 
                                  WHERE RecordType.DeveloperName = 'Adventure'
                                  AND Related_Campaign__c != null
                                  AND StartDate >= :cSDate
                                  AND EndDate <= :cEDate];
        List<CampaignMember> cms = new List<CampaignMember>();
        integer y = -1;
        for (Integer x=0; x<camp_with_all.size(); x++) {
            cms = [SELECT id, Name from CampaignMember
                  where campaignId = :camp_with_all[x].id];
            if (cms.size()>0) { 
                y = x;
                x = camp_with_all.size() + 1;
            }
        }
        Fee__c fee = [SELECT id from Fee__c where Activity_Type__c = 'Cycling' limit 1];
        //add an adventure campaign that does not have volunteer campaign
        TestDataFactory.CreateCampaigns('Tst1234', 'Adventure', 'Cycling', 1, 0, date.Today(), date.Today(), fee.id);
        Campaign soloCamp = [SELECT id, Related_Campaign__c from Campaign 
                             where Name Like 'Tst1234%'
                             and StartDate = today
                             Limit 1];
        soloCamp.Related_Campaign__c = null;
        update soloCamp;

        List<CampaignMember> theVols = new List<CampaignMember>();
        List<Campaign> volCamp = new List<Campaign>();
        
        
        //now for the test
        ApexPages.StandardController std = new ApexPages.StandardController(camp_with_all[y]);
        printCampaignRosters pCR = new printCampaignRosters(std);
        PageReference newPage = pCR.autoRun();
        String pv0Call = newPage.getParameters().get('pv0');
        system.debug('pv0 = '+ pv0Call);
        String pv1Call = newPage.getParameters().get('pv1');
        system.debug('pv1 = '+ pv1Call);
        String strCampId = camp_with_all[y].id;
        system.debug('campaign string = ' + strCampId);  
        String volCampId = camp_with_all[y].Related_Campaign__c;
        system.debug('volcamaping string = ' + volCampId);
        system.assertEquals(strCampId.substring(0, 15), pv0Call);
        system.assertEquals(volCampId.substring(0, 15), pv1Call);
        
        //run the test again with a campaign without volunteer campaign
        std = new ApexPages.StandardController(soloCamp);
        pCR = new printCampaignRosters(std);
        newPage = pCR.autoRun();
    }
}