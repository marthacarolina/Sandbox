public class theController {

    String searchText;
    List<Contact> results;

    public String getSearchText() {
        return searchText;
    }

    public void setSearchText(String s) {
        searchText = s;
    }

    public List<Contact> getResults() {
        return results;
    }

    public PageReference doSearch() {
        results = (List<Contact>)[FIND :searchText IN Name Fields RETURNING Contact(Name, Email, Phone WHERE participant__c = True)][0];
        return null;
    }
}