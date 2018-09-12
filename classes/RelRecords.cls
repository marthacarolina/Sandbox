public with sharing class RelRecords {
    @AuraEnabled
    public Campaign camp {get;set;}
    @AuraEnabled
    public Campaign RelatedCampaign {get;set;}
    @AuraEnabled
    public List<GW_Volunteers__Volunteer_Job__c> VolJobs {get;set;}
    @AuraEnabled
    public List<GW_Volunteers__Volunteer_Shift__c> VolShifts {get;set;}
    public RelRecords () {
        camp = new Campaign();
        RelatedCampaign = new Campaign();
        VolJobs = new List<GW_Volunteers__Volunteer_Job__c>();
        VolShifts = new List<GW_Volunteers__Volunteer_Shift__c>();
    }
}