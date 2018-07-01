@isTest
private class TestDeleteCampTrigger {
    //test for whenCampaignDeleted Campaign Trigger for deleted campaign
    //
    @isTest static void testingCampaignTriggerDel() {
        TestDataFactory.CreateGAU('Activity Fees');
        id fee = TestDataFactory.CreateFee('Cycling', 10);
        
        TestDataFactory.CreateCampaigns('Campaign', 'Adventure', 'Cycling', 3, 0, Date.TODAY(), Date.TODAY(), fee);
        TestDataFactory.CreateCampaigns('Campaign', 'Fundraising', 'Cycling', 3, 6, Date.TODAY(), Date.TODAY(), fee);      
        TestDataFactory.CreateCampaigns('Campaign', 'Volunteers_Campaign', 'Cycling', 1, 9, Date.TODAY(), Date.TODAY(), fee);      
        //make sure one of the adventure campaigns doesn't have a volunteer campaign            
        Campaign updateCamp = [SELECT id, Related_Campaign__c FROM Campaign
                                  WHERE Name = 'Campaign2'];
        updateCamp.Related_Campaign__c = NULL;
        update updateCamp;
        List<Campaign> insertedCampaigns = [Select id, Name, Related_Campaign__c,
                                           RecordTypeId, StartDate, EndDate
                                           FROM Campaign Order By RecordType.Name];
        
        //The following code makes and inserts Campaign Member records for the
        //campaigns that were just inserted.
        TestDataFactory.CreateContacts(40, 0);
        List<Contact> conts = [Select id from Contact];
        TestDataFactory.CreateCMStatusDefault('Cycling');
        List<String> statai = new List<String>{'Signed Up', 'Attended', 'Signed Up'};
        TestDataFactory.CreateCampaignMembers(insertedCampaigns, conts, 3, statai);
         

        List<CampaignMember> theCMs = new List<CampaignMember>();
                     
        //Now for the test            
        try
        {
            delete insertedCampaigns;
            System.assert(false);
        }
        catch (DMLException e)
        {
            // Check that the trigger interrupts the deletion
            Boolean statusException = e.getMessage().contains('You must change the Member status to anything but Attended before deleting a Campaign.') ? true : false;
            Boolean volunteerException =  e.getMessage().contains('Before deleting the campaign you must delete the volunteer campaign associated with it.') ? true : false;
            Boolean expectedExceptionThrown = statusException || volunteerException;
            System.AssertEquals(expectedExceptionThrown, true);
            //system.assertEquals('Before deleting the campaign you must delete the volunteer campaign associated with it.', e.getMessage());
        }
    }
}