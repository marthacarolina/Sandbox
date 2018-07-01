@isTest
public class QAMonthlyStaffController_Test {
    @isTest
    public static void doTheTest()
    {
        id fee = TestDataFactory.CreateFee('Cycling', 10);

        TestDataFactory.CreateGAU ('Activity Fees');
        TestDataFactory.CreateCMStatusDefault('Cycling');
        TestDataFactory.CreateCMStatusDefault('Outreach');
        TestDataFactory.CreateCMStatusDefault('Fundraising');
        
        TestDataFactory.CreateCampaigns('Test Campaign ', 'Adventure', 'Camping', 
                                        1, 0, date.newInstance(2017,1,1 + 3),
                                        date.newInstance(2017,1,1 + 3), fee);
        TestDataFactory.CreateCampaigns('Test Campaign ', 'Adventure', 'Hiking', 
                                        2, 1, date.newInstance(2017,1,1 + 15),
                                        date.newInstance(2017,1,1 + 15), fee);
        TestDataFactory.CreateCampaigns('Test Campaign ', 'Fundraising', 'Outreach', 
                                        1, 3, date.newInstance(2017,1,1 + 6),
                                        date.newInstance(2017,1,1 + 6), fee); 
        TestDataFactory.CreateCampaigns('Test Campaign ', 'Fundraising', 'Fundraising', 
                                        1, 4, date.newInstance(2017,1,1 + 10),
                                        date.newInstance(2017,1,1 + 10), fee); 
        TestDataFactory.CreateCampaigns('Test Campaign ', 'Fundraising', 'Hiking', 
                                        2, 5, date.newInstance(2017,1,1 + 10),
                                        date.newInstance(2017,1,1 + 10), fee);         

        // get the recordtype id's for Campaign
        Map<String, id> recTypeIds = new Map<String, id>();
        List<RecordType> recs = [select id, Name, DeveloperName from RecordType
                                where sObjectType = 'Campaign'];
        for (RecordType rt : recs)
            recTypeIds.put(rt.DeveloperName, rt.id);
        
        List<Campaign> insertedCamps = [select id, Name, 
                                        Related_Campaign__c, RecordTypeId
                                        From Campaign
                                        Order by RecordType.Name];
        system.debug('insertedCamps.size()' + insertedCamps.size());
        List<Campaign> advCamp = new List<Campaign>();
        List<Campaign> volCamp = new List<Campaign>();
        List<Campaign> fundCamp = new List<Campaign>();
        for (Campaign c : insertedCamps)
        {
            if (c.RecordTypeId == recTypeIds.get('Adventure'))            
                advCamp.add(c);            
            else 
                if (c.RecordTypeId == recTypeIds.get('Fundraising'))
                    fundCamp.add(c);
                else
                    if (c.RecordTypeId == recTypeIds.get('Volunteers_Campaign'))
                       volCamp.add(c);                
        }
        
        //insert contacts
        TestDataFactory.CreateContacts(95, 0);
        //get the contacts just inserted and update fields
        List<Contact> contacts = [SELECT id, LastName, Participant__c, Relationship_w_Participant__c,
                                 Caregiver__c FROM Contact Order By LastName];
        
        Boolean part = True;
        Boolean fof = false;
        Boolean caregiver = false;
        for (Integer x = 0; x < contacts.size(); x++)
        {
            if (x > 15)
            {
                part = false; fof = true;
            }
            if (x > 20)
            {
                fof = false; caregiver = true;
            }
            contacts[x].Participant__c = part;
            contacts[x].Relationship_w_Participant__c = fof;
            contacts[x].Caregiver__c = caregiver;
        }
        update contacts;
        // Insert Campaign Members
        // first insert the status defaults for the campaign types
        TestDataFactory.CreateCMStatusDefault('Camping');
        TestDataFactory.CreateCMStatusDefault('Hiking');
        TestDataFactory.CreateCMStatusDefault('Fundraising');
        TestDataFactory.CreateCMStatusDefault('Outreach');
        List<Contact> conts1 = new List<Contact>();
        for (integer x = 0; x<65; x++)
            conts1.add(contacts[x]);        
        List<Contact> conts2 = new List<Contact>();
        for (integer x = 66; x<80; x++)
            conts2.add(contacts[x]);   
        List<Contact> conts3 = new List<Contact>();
        for (integer x = 81; x<95; x++)
            conts3.add(contacts[x]);   
        List<String> statuses = new List<String>{'Attended'};       
        TestDataFactory.CreateCampaignMembers(advCamp, conts1, 3, statuses);
        statuses.clear(); statuses.add('Staff');
        TestDataFactory.CreateCampaignMembers(fundCamp, conts2, 2, statuses);
        statuses.clear(); statuses.add('Completed');
        TestDataFactory.CreateCampaignMembers(volCamp, conts3, 2, statuses);

        //Start test
        //instantiate page
        PageReference QAStaffReport = page.QAMonthlyStaffVF;
        test.setCurrentPage(QAStaffReport);
        ApexPages.currentPage().getParameters().put('m', '1');
        ApexPages.currentPage().getParameters().put('y', '2017');
        QAMonthlyStaffController controller = new QAMonthlyStaffController();
        controller.printPDFReport();
        system.assertEquals('2017-01-01', controller.beginRange);
        system.assertEquals(4,controller.allCampaignsByType.size());
    }
    
}