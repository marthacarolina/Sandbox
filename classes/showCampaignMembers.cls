public class showCampaignMembers 
{
 public String nameQuery {get; set;}
 public List<Contact> contacts {get; set;}
 Public List<CampaignMember> participants {get; set;}
 private ApexPages.StandardController std;
 
 public PageReference executeSearch()
 {
  String queryStr='%' + nameQuery + '%';
  contacts=[select id, Name, Participant__c 
            from Contact 
            where name like :queryStr];
            
  return null;
 }
  
 public showCampaignMembers(ApexPages.StandardController stdCtrl)
 {
   Std = stdCtrl;
    Participants = [SELECT id, FirstName, LastName, Email, Status FROM CampaignMember
        WHERE CampaignId = :std.getId() ORDER BY FirstName];
  }

}