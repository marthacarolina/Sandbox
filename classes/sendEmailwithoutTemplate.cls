public class sendEmailwithoutTemplate {
    private Campaign campaign;
    
    public void SendTheEmail(){
        List<Messaging.SingleEmailMessage> mails = 
  				new List<Messaging.SingleEmailMessage>();
        Campaign camp = [Select id, description, Email_Message__c, 
                         		StartDate, Type 
                         from Campaign Where id = '7014B000000pmgs'];
        List<Contact> contacts = [Select id, FirstName, LastName, email, Total_Activity_Days__c from Contact 
                                  where Name = 'Martha Vance'];
        Email_Content__c emailBody = [Select Name, For_Participants__c, For_Volunteers__c,
                        			Type_of_Email__c, Campaign_Type__c//, Body__c
                        			FROM Email_Content__c 
                        			WHERE For_Participants__c = True AND
                                    Campaign_Type__c = :camp.Type
                                    Limit 1];
        system.debug('contacts.size() = '+ contacts.size());
        for (Contact c : contacts)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            toAddresses.add(c.email);
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Daring Adventures');
            mail.setSubject('Reminder of your upcoming adventure');
            //String body = ThankYou(c, camp, emailBody);
            String body = Reminder(c,camp,emailBody);
            mail.setHtmlBody(body);
        	mails.add(mail);
        }
        messaging.sendEmail(mails);
    }
    
    public String Reminder(Contact c, Campaign camp, Email_Content__c emailBody)
    {        
        String body = '<h3 >Hi ' + c.FirstName + ',</h3><br />';
        body = body + camp.Email_Message__c + '<br />' ;//+ emailBody.Body__c;
		body = body + '<p>We are looking forward to our adventure with you!</p>';
		body = body + '<br />Your friends at Daring Adventures,<br/>';
        body = body + UserInfo.getName() + '<br />';
        body = body + UserInfo.getUserEmail()+'<br />';
        body = body + '555-555-5555';
        return body;
    }
    
    public String ThankYou(Contact c, Campaign camp)
    {
        String body = '<h3 >Hi Participant.FirstName,</h3>';
		body = body + '<br /><p>Congratulations! You have completed XXXXXX ';
        body = body + 'Active Days with Daring Adventures during your recent adventure. ';
        body = body + 'We were thrilled that you were able to join us.</p>';
		body = body + '<br />campaign.email_message__c<br /><p>Do not forget to look for more adventures ';
        body = body + 'in our calendar <a href="http://www.daring-adventures.org/">';
		body = body + 'www.daring-adventures.org</a> and sign up for your next adventure.</p>';
		body = body + '<p>We are looking forward to our next adventure with you!</p>';
		body = body + '<br />Your friends at Daring Adventures,<br/>';
        body = body + 'user.name <br />';
        body = body + 'user.email';
        body = body.replace('Participant.FirstName', c.FirstName);
        String activity_days = ''+ c.Total_Activity_Days__c;
        body = body.replace('XXXXXX', activity_days);
        body = body.replace('campaign.email_message__c', camp.email_message__c);
        body = body.replace('user.name', UserInfo.getName());
        body = body.replace('user.email', UserInfo.getUserEmail());
        return body;
    }
}