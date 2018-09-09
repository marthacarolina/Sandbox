@isTest
public class VolSignUpController_Test {
    @isTest
    private static void VolSignUpController_Test() {
        //create a campaign for volunteer to sign up on
        id fee = TestDataFactory.CreateFee('Cycling', 10);
        TestDataFactory.CreateGAU('Activity Fees');
        TestDataFactory.CreateContacts(2, 0);
        
        List<Contact> contacts = [SELECT ID, FirstName, LastName, Volunteer__c
                                 FROM Contact];
        //Make one contact[0] a qualified volunteer  
        contacts[0].email = 'contact0@gmail.com';          
        contacts[0].Fingerprint_Clearance__c = true;
        contacts[0].Fingerprint_Clearance_Expiration_Date__c = date.today() + 600;
        contacts[0].First_Aid_Certification__c = true;
        contacts[0].First_Aid_Certification_Expiration_Date__c = date.today() + 600;
        contacts[0].CPR_Certificate__c = true;
        contacts[0].CPR_Certificate_Expiration_Date__c = date.today() + 600;
        contacts[0].Volunteer__c = true;   
        update contacts[0];        
        TestDataFactory.CreateCampaigns('campaign', 'Adventure', 'Cycling', 1, 1, 
                                        date.today()-1, date.today()-1, fee);
        List<Campaign> camps = [SELECT id, Name, Related_Campaign__c,
                                StartDate, EndDate
                                from Campaign
                                where RecordType.Name = 'Adventure'];
        TestDataFactory.CreateJobShift(camps);
        //instantiate the VF page
        PageReference jobToSignUP = page.VolJobSignUp;
        jobToSignUP.getParameters().put('id',camps[0].id);
        test.setCurrentPage(jobToSignUP);
        VolSignUpController controller = new VolSignUpController();
        boolean starter = controller.getBegin();
        //test with errors
        //No First Name
        controller.volunteer.FirstName = '';
        controller.volunteer.LastName = contacts[0].LastName;
        controller.volunteer.email = 'contact0@gmail.com';
        PageReference response = controller.save();
        List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        system.assert(true,pageMessages[0].getSummary().contains('Please type in the First Name'));
        //test with no last name
        controller.volunteer.FirstName = contacts[0].FirstName;
        controller.volunteer.LastName = '';
        response = controller.save();
        pageMessages = ApexPages.getMessages();
        system.assert(true,pageMessages[0].getSummary().contains('Please type in the Last Name'));
        // test with no email
        controller.volunteer.LastName = contacts[0].LastName;
        controller.volunteer.Email = '';
        response = controller.save();
        pageMessages = ApexPages.getMessages();
        system.assert(true,pageMessages[0].getSummary().contains('You must enter an Email address'));

        // test with a contact that is not found        
        controller.volunteer.FirstName = contacts[0].FirstName;
        controller.volunteer.LastName = contacts[0].LastName;
        controller.volunteer.email = 'cualquierDireccion@gmail.com';
        response = controller.save();
        pageMessages = ApexPages.getMessages();
        system.assert(true,pageMessages[0].getSummary().contains('We do not have a volunteer with the email'));
        
        //test with a campaign that doesn't require Qualified Volunteers
        controller.volunteer.FirstName = contacts[0].FirstName;
        controller.volunteer.LastName = contacts[0].LastName;
        controller.volunteer.email = contacts[0].Email;
        response = controller.save();
        Integer x = [Select count() from GW_Volunteers__Volunteer_Hours__c];
        integer y = [SELECT count() from Task];        
        system.assertEquals(1, y);
        system.assertEquals(1, x);
        
        //test with a campaign that requires qualified volunteers with
        //unqualified volunteer
        camps[0].Only_Qualified_Volunteers__c = true;
        Campaign vCamp = [SELECT id, Only_Qualified_Volunteers__c 
                          FROM Campaign
                          WHERE id = :camps[0].Related_Campaign__c];
        vCamp.Only_Qualified_Volunteers__c = true;
        update vCamp;
        update camps[0];
        controller = new VolSignUpController();
        jobToSignUP.getParameters().put('id',camps[0].id);
        test.setCurrentPage(jobToSignUP);
        starter = controller.getBegin();
        controller.volunteer.FirstName = contacts[0].FirstName;
        controller.volunteer.LastName = contacts[0].LastName;
        controller.volunteer.email = contacts[0].Email;
        response = controller.save();
        x = [Select count() from GW_Volunteers__Volunteer_Hours__c];
        y = [SELECT count() from Task];        
        system.assertEquals(1, y);
        system.assertEquals(1, x);
        
        //test with an qualified volunteer and a campaign that requires qualified volunteers
        contacts[0].Volunteer_Orientation__c = date.today() - 20;
        update contacts[0];

        controller = new VolSignUpController();
        jobToSignUP.getParameters().put('id',camps[0].id);
        test.setCurrentPage(jobToSignUP);
        starter = controller.getBegin();
        controller.volunteer.FirstName = contacts[0].FirstName;
        controller.volunteer.LastName = contacts[0].LastName;
        controller.volunteer.email = contacts[0].Email;
        response = controller.save();
        x = [Select count() from GW_Volunteers__Volunteer_Hours__c];
        y = [SELECT count() from Task];        
        system.assertEquals(2, y);
        system.assertEquals(2, x);
    }
}