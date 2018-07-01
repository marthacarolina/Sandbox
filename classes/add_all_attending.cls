global class add_all_attending {
    @InvocableMethod
    global static void TotParticipantDays (List<Campaign> adventures){
        List<Campaign> updAdv = new List<Campaign>();
        //retrieve the volunteer campaign corresponding to the adventure campaings
        //first make a list with all the volunteer campaign id's to retrieve all the vol campaigns
        list<id> volId = new list<id>();
        for (campaign c : adventures){
            volId.add(c.Related_Campaign__c);
            updAdv.add(c);
        }
        //using the list of id's retrieve the volunteer campaigns
        map<id, campaign> volunteers = new map<id, campaign>([SELECT id, GW_Volunteers__Number_of_Volunteers__c
                                                             FROM Campaign WHERE id IN :volId]);
        //calculate the Total Participant Days for each campaign and 
        for (campaign c : updAdv){
            integer days = c.EndDate.daysBetween(c.StartDate) + 1;
            system.debug('days = ' + days);
            integer totAttending = integer.valueOf(c.Head_Count__c) + 
                integer.valueOf(volunteers.get(c.Related_Campaign__c).GW_Volunteers__Number_of_Volunteers__c);
            system.debug('totAttending = ' + totAttending);
            c.Participant_Days__c = days * totAttending;
            system.debug('participant days = ' + c.Participant_Days__c);
        }
        update updAdv;
    }

}