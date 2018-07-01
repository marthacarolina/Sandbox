//This class prints the QA Donor reports - both, the annual and the Quarterly
//
//Martha Vance

public class QAAnnualController extends QAReports {
    public integer totalDonations {get; set;} //total number of donations during time period
    public string totalPerAnnum {get;set;} // total amount of donations during time period
    public integer totalFirsts {get; set;} //total of first time donors during time period
    public integer totalDonors {get; set;} //total number of individual/household donors during time period
    public string IsCsv {get; set;} //true when the output is an exel file
    public List<PageDonor> pageBrokenDonorLines {get; set;}  //List of report pages      
    
   
    public void QAAnnualController(){}    
    
    //this method is called from the QAannualDonorVF and the QAannualDonorExel 
    //visualforce pages
    public void AnnualQA(){        
        //get the year from the parameters (in the URL)
        year = ApexPages.currentPage().getParameters().get('y');
        IsCsv = ApexPages.currentPage().getParameters().get('f');
        getMonthYear('01', year);
        //the previous method sets the endRange to the end of the month, change to end of year
        endRange = year + '-12-31';        
        //call the report and populate the donors list with the information for
        //each household or account
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where
                                    DeveloperName = 'QA_Donors_Annual'];
        String reportId = (String)reportList.get(0).get('Id');
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata rm = describe.getReportMetadata();
        Reports.ReportFilter filter1 = rm.getReportFilters()[1];
        Reports.ReportFilter filter2 = rm.getReportFilters()[2];
        filter1.setValue(beginRange);
        filter2.setValue(endRange);
        // Run the report - syncronously
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, rm, true);
        //Parse the information in the report
        List<donor> donors = DonationsList(results, true);
        //separate the information by pages (for pagination)
        prepareDonorLinesForPrinting(donors);
    }

    public void QuarterlyDonors()
    {
        //get the parameters q - quarter and y - year
        String qStr = ApexPages.currentPage().getParameters().get('q');
        year = ApexPages.currentPage().getParameters().get('y');
        //set up the date for the begining and ending of the range
        getQuarterYear(qStr, year);
        date beginQuarter = date.valueOf(beginRange);
        //call the report and populate the allDonors list with the information for
        //each household or account "Donations by Account"
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where
                                    DeveloperName = 'QA_Donors_Annual'];
        String reportId = (String)reportList.get(0).get('Id');
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata rm = describe.getReportMetadata();
        Reports.ReportFilter filter1 = rm.getReportFilters()[1];
        Reports.ReportFilter filter2 = rm.getReportFilters()[2];
        filter1.setValue(beginRange);
        filter2.setValue(endRange);
        // Run the report - syncronously
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, rm, true);
        if (results != null)
        {
            List<donor> donors = DonationsList(results, false);
            system.debug('donors.size() = '+ donors.size());
            prepareDonorLinesForPrinting(donors); 
        }
    }
    
    //once the report has been run with the appropriate filters this method parses the information
    public List<donor> DonationsList(Reports.ReportResults results, boolean oneYear)
    {   
        system.debug('in DonationsList');
        totalFirsts = 0;
        List<donor> allDonors = new List<donor>();
        List<donor> firstDonors = new List<donor>();
        Reports.Dimension dim = results.getGroupingsDown();
        List<Reports.GroupingValue> groupingVal = dim.getGroupings();
        // the number of groupings is the number of donors
        totalDonors = groupingVal.size();
        totalDonations = 0;
        Integer tots = 0;
        for (Reports.GroupingValue gV : groupingVal)
        {
            String accountName = gv.getLabel();
            String factMapKey = gV.getKey() + '!T';
            Reports.ReportFactWithDetails factDetails =
                (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);
            //detailRows holds all the rows within the group. In this case all the donations
            //made by one donor during the time period.
            List<Reports.ReportDetailRow> detailRows = factDetails.getRows(); 
            totalDonations = totalDonations + detailRows.size();
            List<Reports.ReportDataCell> firstRowCells = detailRows[0].getDataCells();
            //get the donor information from the first row of each grouping
            donor oneDonor = new donor();
            donor newDonor = new donor();
            oneDonor.name = (string) firstRowCells[2].getValue();
            if (oneDonor.name == null) oneDonor.name = accountName;
            if (IsCsv == 'true' && oneDonor.name.contains(',')) {
                oneDonor.name = oneDonor.name.remove(',');
            }
            oneDonor.street = (string) firstRowCells[4].getLabel();
            oneDonor.city = (string) firstRowCells[5].getLabel();
            oneDonor.state = (string) firstRowCells[6].getLabel();
            oneDonor.zipcode = (string) firstRowCells[7].getLabel();
            oneDonor.phone = (string) firstRowCells[8].getLabel();
            oneDonor.email = (string) firstRowCells[9].getLabel();
            oneDonor.firstGift = (date) firstRowCells[10].getValue();
            //get the total donations for this account
            List<Reports.SummaryValue> sumVal = factDetails.getAggregates();
            oneDonor.totalDonation = (string) sumVal[0].getLabel();
            if (oneDonor.firstGift >= date.valueOf(beginRange) &&  
               oneDonor.firstGift <= date.valueOf(endRange))     
            {
                totalFirsts = totalFirsts + 1;
                firstDonors.add(oneDonor);
            }            
            if (IsCsv == 'true' && oneDonor.totalDonation.contains(',')) 
            {
                oneDonor.totalDonation = oneDonor.totalDonation.remove(',');
            }
            allDonors.add(oneDonor);
        }
        Reports.ReportFactWithDetails totals = (Reports.ReportFactWithDetails) results.getFactMap().get('T!T');
        List<Reports.SummaryValue> totVal = totals.getAggregates();
        totalPerAnnum = (string) totVal[0].getLabel();
        if (oneYear) return allDonors;
        else return firstDonors;
    }

   
    //splits the donors into an approximate number of lines that can be 
    //displayed per page
    private void prepareDonorLinesForPrinting(List<donor> donors)
    {
        //controls how many lines are displayed on page 1
        Integer first_break = 45;
        //controls how many lines are displayed on subsequent pages
        Integer subseq_breaks = 50;
        pageBrokenDonorLines = new List<PageDonor>();
        
        PageDonor pageOfDonors = new PageDonor();
        Integer counter = 0;
        
        boolean firstBreakFound = false;
        boolean setSubSeqBreak = false;        
        Integer breakPoint = first_break;
        integer x = 0;
        for(donor d : donors)
        {
            system.debug('donor ' + x); x++;
            if(counter <= breakPoint)
            {
                pageOfDonors.ListOfDonors.add(d);

                counter++;
            }
            if(counter == breakPoint)
            {
                if (!firstBreakFound) 
                {
                    firstBreakFound = true;
                    setSubSeqBreak  = true;
                }
                counter = 0;
                pageBrokenDonorLines.add(pageOfDonors);
                pageOfDonors = new PageDonor();
            }
            if(setSubSeqBreak) 
            {
                breakPoint = subseq_breaks;
                setSubSeqBreak = false;
            }
        }
        //if we have finished looping and have some quotes left let's assign them
        if(!pageOfDonors.ListOfDonors.isEmpty())
            pageBrokenDonorLines.add(pageOfDonors);
    }
    
    public class PageDonor{
        public List<donor> listOfDonors {get; set;}
        public PageDonor() {
            this.listOfDonors = new List<donor>();
        }
    }
    
    public class donor {
        public string name {get; set;}
        public string street {get; set;}
        public string city {get; set;}
        public string state {get; set;}
        public string zipcode {get; set;}
        public string totalDonation {get; set;}
        public string phone {get; set;}
        public string email {get; set;}
        public date firstGift {get; set;}
        public donor (){}
    }
}