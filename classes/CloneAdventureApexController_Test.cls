@isTest
public class CloneAdventureApexController_Test {
    @isTest
    private static void testCloneAdventure(){
        id fee = TestDataFactory.CreateFee('Cycling', 15);
        TestDataFactory.CreateGAU('Activity Fees');
        TestDataFactory.CreateCMStatusDefault('Cycling');
        TestDataFactory.CreateCMStatusDefault('Kayaking');
        TestDataFactory.CreateCMStatusDefault('Backpacking');
        TestDataFactory.CreateCMStatusDefault('Hiking');
        TestDataFactory.CreateCampaigns('Testing ', 'Adventure', 'Cycling', 1, 1, date.today() - 10, date.today() - 10, fee);
        List<Campaign> camps = [select id, Name, RecordTypeId, Type, Description,
                                StartDate, EndDate, Related_Campaign__c
                                from Campaign Where Name = 'Testing 1'];
        TestDataFactory.CreateJobShift(camps);
        
        //test the retrival of records
        RelRecords recsToClone = CloneAdventureApexController.getRelatedRecords(camps[0].id);
        system.assertEquals('Testing 1', recsToClone.camp.name);
        system.assertEquals('Volunteer Testing 1', recsToClone.RelatedCampaign.Name);
        system.assertEquals('PHoenix', recsToClone.VolJobs[0].GW_Volunteers__Location_City__c);
        //call cloneCampaign -- all paramenters must be string
        string campToCloneID = (string) camps[0].id;
        string stDate = '02018-10-220';
        id newClone = CloneAdventureApexController.cloneCampaign(campToCloneID, 
                                                                 'Testing Clone', 
                                                                 stDate, 
                                                                 stDate);
        Integer totCampaigns = [select count() from Campaign];
        system.assertEquals(4, totCampaigns);                
    }
}