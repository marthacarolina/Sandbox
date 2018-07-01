@isTest
private class TestChangTypeofCampaign {
    @isTest static void TestChangeType() {        
        // create records to test
        // bulk validation
        TestDataFactory.CreateGAU ('Activity Fees');
        id fee = TestDataFactory.CreateFee('Cycling', 10);
        TestDataFactory.CreateCampaigns('Adventure ', 'Adventure', 
                                        'Cycling', 2, 0, 
                                        Date.TODAY(), Date.TODAY(), fee);
        TestDataFactory.CreateCampaigns('MailChimp ', 'Adventure', 
                                        'Cycling', 2, 2, 
                                        Date.TODAY(), Date.TODAY(), fee);
        Integer totAdvIns = [SELECT Count() from Campaign
                            WHERE RecordType.Name = 'Adventure'];
        system.assertEquals(4, totAdvIns);
        //testing the class
        ChangetheType.ChangeTypeforMC();
        Integer totChanged = [SELECT COUNT() FROM Campaign WHERE 
                              RecordType.DeveloperName = 'Fundraising'];
        System.assertEquals(2, totChanged);
    }
}