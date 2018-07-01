public class ImportAZGives {

    private ApexPages.StandardController std;
    public Integer annonCount {get;set;}
    public Integer donorCount {get;set;}
    public Integer newContactCount {get;set;}
    public Integer notMatchedCount {get;set;}
    public Integer involvedCount {get;set;}
        public List<AZGives_Donor__c> donors;
        public map<String, AZGives_Donor__c> map_donors;
        public List<Opportunity> oppys;
        public List<Task> taskList;
    public Id campaignId {get;set;}
        public List<Contact> newContacts;
        public List<AZGives_Donor__c> annon;        
    
    public ImportAZGives(ApexPages.StandardController stdCtrl){
        std=stdCtrl;
        CampaignId = std.getId();
        annonCount = 0;
        donorCount = 0;
        newContactCount = 0;
        notMatchedCount = 0;
        involvedCount = 0;
        annon = new List<AZGives_Donor__c>();
                oppys = new List<Opportunity>();
                taskList = new List<Task>();
                for (Integer x=0 ; x<30; x++)
        {
            boolean done = checkWithContacts(); 
            if (done) x = 31;
        }
    }
    
    public Boolean checkWithContacts() 
    {
            donors = [SELECT id, Amount__c, Transaction_Date_Time__c, Anonymous__c,
                 FirstName__c, LastName__c, Email__c, Phone_Number__c,
                 Address_1__c, Address_2__c, City__c, State__c, Country__c,
                 Zip_Code__c, Cover_Fees__c, In_Memory__c, Comments__c, Get_Involved__c,
                 Campaign_Name__c, Processed__c, Matched_Email__c, Not_Found__c 
                 FROM AZGives_Donor__c WHERE 
                 (Not_Found__c = false AND Processed__c = false AND 
                  Matched_Email__c = false) Limit 200];
        system.debug('donors.size() = '+ donors.size());
        donorCount = donorCount + donors.size();
        if (donors.size()>0)
        {
                map_donors = new map<String, AZGives_Donor__c>();
            system.debug('map_donors.size() = '+ map_donors.size());
                //this for is just to populate the map of donors
                for (AZGives_Donor__c donor : donors)
                {
                    //if the email already exists do not add it to the map
                    //if it's FULLY annonymous add to annon list don't add to map
                    system.debug('donor = ' + donor);
                    if ( ! map_donors.containsKey(donor.Email__c))
                    if (donor.Anonymous__c.contains('Fully')) annon.add(donor); 
                        else
                        map_donors.put(donor.Email__c, donor);
                }
                        system.debug('map_donors.size() = '+ map_donors.size());
            SearchContacts();
            return false;
        }
        else return true;
    }
    
    public void SearchContacts(){    
        //get a list of the contacts that match emails in AZGives file
        //if the donor is found in contacts but names dont match Processed 
        //is false and Matched_Email__c is true a new list of updated donors
        //is made and the donors map if updated
        system.debug('in SearchContacts');
        List<Contact> conts = [SELECT id, FirstName, LastName, Email from Contact
                              WHERE Email IN :map_donors.keySet()];
        system.debug('conts size = '+ conts.size());
        List<AZGives_Donor__c> updatedDonors = new List<AZGives_Donor__c>();
        for (Contact c : conts){
            AZGives_Donor__c donor = map_Donors.get(c.Email);
            system.debug('contact name '+ c.FirstName +' ' + c.LastName);
            system.debug('donor First Name '+ donor.FirstName__c +
                        ' donor Last Name ' + donor.LastName__c);
            if (c.FirstName == donor.FirstName__c && c.LastName == donor.LastName__c)
            {
                oppys.add(newOppy(c, donor));
                donor.Processed__c = true;
                system.debug('the donor was processed and a new opportunity was created');
            }
            Else
            {
                donor.Processed__c = false;
                donor.Matched_Email__c = true;
                notMatchedCount = notMatchedCount + 1;
                system.debug('the donor name didnt match there is no new opportunity and Matched is true');
            }
            updatedDonors.add(donor);
            map_Donors.put(c.Email, donor);
        }
        //if there were more donors than contacts then it means some
        //donors need to be added as contacts (it could mean that there
        //are double donations from the same contact)
        If (map_Donors.size() > conts.size())
        {
                        addNewContacts();
            //once the new contacts are created insert the records then
            //call the method that adds an opportunity to the list
            //and a task if needed            
            if (newContacts.size() > 0){
                insert newContacts;
                for (Contact newC : newContacts){  
                        system.debug('newC.id = '+ newC.id);
                    AZGives_Donor__c donor = map_Donors.get(newC.Email);

                        oppys.add(newOppy(newC, donor));
                }
            }
        }

        //handle the annonymous donations - make opportunities linked to an
        //account marked as Anonymous
        system.debug('annon size = '+ annon.size());
        if (annon.size()>0) ProcessAnnonymous();        
        //update the AZGives object. If the Processed__c false
        //(means no oppy was created) and 
        //Matched_Email__c false then Not_Found__c is true
        //which means that if Not_Found__c refers to the donors whose
        //emails match but names don't match an existing contact
        donors = map_Donors.values();        
        for (AZGives_Donor__c d : donors)
            if (!d.Processed__c && d.Matched_Email__c)
                d.Not_Found__c = true;
        update donors;

        //now insert the new opportunities and new tasks
        insert oppys;
        involvedCount = involvedCount + taskList.size();
        insert taskList;
        
    }
    
        public void addNewContacts()
        {
        // this method creates a contact record and adds it to the list
        // of new contacts.
        // if the donor record hasn't been processed and it hasnt been
        // matched then add a contact record with donor's info
        // after adding the new contact record update Processed__c to true
        List<AZGives_Donor__c> not_Found = map_Donors.values();
        newContacts = new List<Contact>();
        For (AZGives_Donor__c d : not_Found){
                if (!d.Processed__c && !d.Matched_Email__c) {
                newContactCount = newContactCount + 1;
                Contact c = new Contact(FirstName = d.FirstName__c,
                                   LastName = d.LastName__c,
                                   Email = d.Email__c,
                                           MailingStreet = d.Address_1__c,
                                           MailingCity = d.City__c,
                                           MailingState = d.State__c,
                                           MailingPostalCode = d.Zip_Code__c,
                                           Phone = d.Phone_Number__c);
                newContacts.add(c);
                d.Processed__c = true;
                map_Donors.put(d.Email__c, d);
                }
        }
    }

    public Opportunity newOppy(Contact c, AZGives_Donor__c donor){
                String stName = 'Donation '+ c.FirstName + ' ' +
                                c.LastName + '4/3/17';
        String annon1 = '';
        If (donor.Anonymous__c.contains('Partially')) 
            annon1 = 'Donor wishes to remain annonymous'; 
        Opportunity oppy = new Opportunity (Name = stName,
                                        RecordTypeId = '012o0000000xvXl',
                                        npsp__Primary_Contact__c = c.id,
                                        Amount = donor.Amount__c,
                                        CloseDate = donor.Transaction_Date_Time__c.date(),
                                        StageName = 'Closed Won',
                                        Description = annon1,
                                        CampaignId = campaignId);
        if (donor.Get_Involved__c)
                taskList.add(makeTask(c));
        return oppy;
    }
    
    public Task makeTask (Contact c)
    {
        Task contTask = new Task(ActivityDate = Date.Today() + 3,
             Description = c.FirstName + ' ' + c.LastName + ' wants to be involved with DA.',
                        Priority = 'High', Status = 'Not Started', 
                    Subject = 'Need to make CONTACT',
                    WhatId = campaignId, 
                    WhoId = c.id);
        return contTask;
    }
    
    public void ProcessAnnonymous(){
        Account acc = [SELECT id FROM Account WHERE Name = 'Anonymous' limit 1];
        if (acc == null){
            acc = new Account(Name = 'Anonymous');
            insert acc;
        }
        integer x = 1;
        annonCount = annonCount + annon.size();
        for(AZGives_Donor__c d : annon){
            String str = 'Donation AZGives Anonymous ' + x;
                        Opportunity oppy = new Opportunity (Name = str,
                                   AccountId = acc.id,
                                   RecordTypeId = '012o0000000xvXl',
                                   Amount = d.Amount__c,
                                   CloseDate = d.Transaction_Date_Time__c.date(),
                                   StageName = 'Closed Won',
                                   Description = 'Anonymous Donation',
                                   CampaignId = campaignId); 
            x++;
            d.Processed__c = true;
            map_Donors.put(d.Email__c, d);
            oppys.add(oppy);
        }
    }
        
    
}