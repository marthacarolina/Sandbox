public class VolSignUpController {
    public GW_Volunteers__Volunteer_Job__c job {get;set;}
    public GW_Volunteers__Volunteer_Shift__c shift {get;set;}
    public GW_Volunteers__Volunteer_Hours__c hours {get;set;}
    public List<GW_Volunteers__Volunteer_Hours__c> currentVolunteers;
    public Contact volunteer {get;set;}
    public campaign volCampaign {get;set;}
    id campId;
    User userToNotify;
    
    public boolean getBegin(){
        //this method initializes the variables for the VF page
        //retrieve the campaign id from the Visualforce page parameters
        campId = (id)ApexPages.currentPage().getParameters().get('id');
        volCampaign = [SELECT id, Name, 
                       Only_Qualified_Volunteers__c, StartDate, EndDate
                       FROM Campaign
                       WHERE Related_Campaign__c = :campId limit 1];
        job = [SELECT id, Name,
               GW_Volunteers__Description__c,
               GW_Volunteers__Display_on_Website__c,
               GW_Volunteers__Location__c,
               GW_Volunteers__Location_Street__c,
               GW_Volunteers__Location_City__c,
               GW_Volunteers__Location_Zip_Postal_Code__c,
               GW_Volunteers__Location_Information__c
               FROM GW_Volunteers__Volunteer_Job__c
               WHERE GW_Volunteers__Campaign__c = :volCampaign.id];
        shift = [SELECT id, GW_Volunteers__Start_Date_Time__c, 
                 GW_Volunteers__Number_of_Volunteers_Still_Needed__c,
                 GW_Volunteers__Duration__c
                 FROM GW_Volunteers__Volunteer_Shift__c                
                 WHERE  GW_Volunteers__Volunteer_Job__c = :job.id];
        currentVolunteers = [SELECT id, GW_Volunteers__Contact__c
                             FROM GW_Volunteers__Volunteer_Hours__c
                             WHERE GW_Volunteers__Volunteer_Job__c = :job.id
                             AND GW_Volunteers__Volunteer_Shift__c = :shift.id];
        hours = new GW_Volunteers__Volunteer_Hours__c();
        volunteer = new Contact();
        Volunteer_Manager__mdt notify = [Select FirstName__c, LastName__c 
                                         FROM Volunteer_Manager__mdt 
                                         WHERE MasterLabel = 'Volunteer Supervisor'
                                         limit 1];
        userToNotify = [SELECT ID, FirstName, LastName, eMail 
                        FROM User 
                        Where LastName = :notify.LastName__c 
                        AND FirstName = :notify.FirstName__c
                        Limit 1];
        return true;
    }
    
    public PageReference save(){
        string mistake = '';
        If (volunteer.FirstName.length() == 0){
            mistake = 'Please type in the First Name';
        }
        Else{
            if (volunteer.LastName.length() == 0){
                mistake = 'Please type in the Last Name';
            }
            else{
                if (volunteer.Email.length() == 0){
                    mistake = 'You must enter an Email address';
                }
            }
        }
        if (mistake.length() > 0) //if there is an error 
        {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.info, mistake));
            return null;
        }
        //look for an existing contact
        List<Contact> conts = [SELECT id, FirstName, LastName, Email, Volunteer__c, 
                        Qualified_Volunteer__c
                        FROM Contact
                        WHERE Email = :volunteer.Email 
                        AND LastName = :volunteer.LastName];
        Contact cont = new Contact();
        boolean goAhead = false;
        if (conts.size() < 1){
            mistake = 'We do not have a volunteer with the email ' + volunteer.email + 
                ' and last name ' + volunteer.LastName + 
                '. If you have entered the information correctly, and you are a qualified volunteer '+ 
                'please contact our office at (602)-290-0214 or '+ 
                'volunteer@daring-adventures.org ' + 
                'if you want to become a volunteer there is more information in our website ' +
                'www.daring-adventures.org' ;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.info,mistake));
            return null;
        }
        else {
            cont = conts[0];
            //check that the contact hasn't been previously signend up
            for (GW_Volunteers__Volunteer_Hours__c v : currentVolunteers){
                if (cont.id == v.GW_Volunteers__Contact__c){
                    mistake = 'Your request to volunteer in this adventure/event has already been submitted';  
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.info, mistake));
                    return null;
                }
            }
            //if the contact exists check if the campaign is only for qualified volunteers
            if (volCampaign.Only_Qualified_Volunteers__c) {
                //check that the volunteer is qualified
                if (cont.Qualified_Volunteer__c) {
                    goAhead = true;
                }
            }
            else //the volunteer doesn't have to be a Qualified Volunteer
            { 
                goAhead = true;
            }
        }
        //set up the url for the result page - where the user will be directed
        //after signing up
        PageReference showResult = page.VolJobSignupResult;
        if (goAhead) {
            //sign up the volunteer as PROSPECT
            //add task to Sarah to approve or deny, should get email alert with task
            hours.GW_Volunteers__Contact__c = cont.id;
            hours.GW_Volunteers__Status__c = 'Prospect';
            hours.GW_Volunteers__Volunteer_Shift__c = shift.id;
            hours.GW_Volunteers__Number_of_Volunteers__c = 1;
            hours.GW_Volunteers__Start_Date__c = volCampaign.StartDate;
            hours.GW_Volunteers__Volunteer_Job__c = job.id;
            insert hours;
            task task = new task();
            task.OwnerId = userToNotify.id;
            task.Subject = 'A volunteer has signed up for an Adventure/Campaign';
            task.ActivityDate = date.today() + 1;
            //get the base URL for this SF instance
            String approvalURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                '/apex/ApprovalScreen?id=' + campId + '&job=' + job.id + 
                '&shift=' +  shift.id + '&vol=' + cont.id;
            String description = cont.FirstName + ' ' + cont.LastName + 
                ' has signed up for ' + volCampaign.Name;       
            description = description + '. Go to URL: '+ approvalURL;
            task.Description = description;
            insert task;
            sendEmail(true,task);
            //the signup was successful send the user to a screen with
            //toast success!
            showResult.getParameters().put('name',cont.FirstName);
            showResult.getParameters().put('success','1');
            return showResult; 
        }
        else {               
            //send a message to office to let them know of fail attempt to signup.
            sendEMail(false, cont);
            //show result screen telling volunteer he is not set up as a qualified
            //volunteer... contact the office
            showResult.getParameters().put('name',cont.FirstName);
            showResult.getParameters().put('success','0');
            return showResult;
        }                      
    }
    
    // ----------------------------------------------------------------------
    // sendeMail() method
    // - Called by the Save() Method to send a Task Assignment eMail
    // ----------------------------------------------------------------------
    private void sendEMail(Boolean isTask, sObject theObject) {
        string htmlBody = '<HTML><BODY><h3>';
        string textBody = '';
        
        htmlbody += 'The following Task has just been assigned to you.</h3>';
        textBody += 'The following Task has just been assigned to you.\r\r';
        
        // Use this to get the base URL of the SalesForce instance
        string BaseURL = ApexPages.currentPage().getHeaders().get('Host');
        // Create the eMail object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        // Set the TO address
        String[] toAddresses = new String[] {userToNotify.Email};
            mail.setToAddresses(toAddresses);        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('volunteer@daring-adventure.org');

        If (isTask){
            Task t = (Task) theObject;
            // Specify the subject line for your email address.
            mail.setSubject('SalesForce.com Task Assigned: ' + t.subject);
            pageReference tView = new ApexPages.StandardController(t).view();
            htmlBody += '<ul><li>Task: <a href="' + BaseURL + tView.getUrl() + '">' + t.Subject + '</a>';
            htmlBody += '<li>Due Date: ' + t.ActivityDate;
            htmlBody += '</ul></body></html>';        
            textBody += '\t\tSubject: ' + t.subject;
            textBody += '\tTask Link: ' + BaseURL + tView.getUrl();
            textBody += '\tDue Date: ' + t.ActivityDate;
            textBody += '\tPriority: ' + t.Priority;            
        }
        else{
            Contact cont = (Contact) theObject;
            // Specify the subject line for your email address.
            pageReference contView = new ApexPages.StandardController(cont).view();
            mail.setSubject(cont.FirstName + ' ' + cont.LastName + ' attempted to sign up to volunteer.');
            htmlBody += '<br/> ' + cont.FirstName + ' ' + cont.LastName + ' tried to sign up ';
            htmlBody += 'for ' + job.Name + ' on ' +  + ', however this person is not a qualified volunteer and the ';
            htmlBody += 'request was denyed. <br/>';
            htmlBody += 'You can see <a href="' + BaseURL + contView.getUrl() + '"> their record here.</a>';
            textBody += '/t' + cont.FirstName + ' ' + cont.LastName + ' tried to sign up ';
            textBody += 'for ' + job.Name + ', however this person is not a qualified volunteer and the ';
            textBody += 'request was denyed./r';
            textBody += 'You can see their record at Link: ' + BaseURL + contView.getUrl();
        }        
                
        // Set options
        mail.setBccSender(false);
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(textBody);
        mail.setHtmlBody(htmlBody);
        
        // Send the email
        Messaging.SendEmailResult [] sr = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        if (!sr[0].isSuccess()) {
            // Error sending the message; display the error on the page
            Messaging.SendEmailError r = sr[0].getErrors()[0];
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Sending Message: ' + sr[0].getErrors()[0].getMessage() ));
        }      
    }        
}