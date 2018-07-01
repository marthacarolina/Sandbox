public with sharing class CampInvolvment {
    @AuraEnabled
    public String Id {get;set;}
    @AuraEnabled
    public String Name {get;set;}
    @AuraEnabled
    public Date StartDate {get;set;}
    @AuraEnabled
    public Date EndDate {get;set;}
    @AuraEnabled
    public String Type {get;set;}
    @AuraEnabled
    public ID RecordTypeId {get;set;}
    @AuraEnabled
    public String Status {get;set;}
    @AuraEnabled
    public Integer AdventureDays {get;set;}
    @AuraEnabled
    public String CMid {get;set;}
       
}