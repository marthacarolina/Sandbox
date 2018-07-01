public class RetUrlSearchController2 
{
 public String nameQuery {get; set;}
 public List<Contact> contacts {get; set;}
  
 public PageReference executeSearch()
 {
  String queryStr='%' + nameQuery + '%';
  contacts=[select id, Name, Participant__c 
            from Contact 
            where name like :queryStr];
            
  return null;
 }
  
 public RetUrlSearchController2()
 {
  // if query appears in URL, execute it
  String urlQuery=ApexPages.currentPage().getParameters().get('query');
   
  if ( (null!=urlQuery) && (0!=urlQuery.length()) )
  {
   nameQuery=urlQuery;
   executeSearch();
  }
 }
}