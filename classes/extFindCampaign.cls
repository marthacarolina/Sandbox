public class extFindCampaign {
    //extension for Visualforce Page AZGivesDonorProcessingVF   
    Public ApexPages.StandardController Std;
    Public Campaign camp{get;set;}
    Public Campaign campaign{get;set;}
    
    public extFindCampaign(ApexPages.StandardController stdCtrl)
    {
        Std = stdCtrl;
        if (campaign == null)       
            campaign = [SELECT id, Name, StartDate, EndDate, Description FROM Campaign
                        WHERE Name = 'AZGives Day 2017' Limit 1];            
    }
    
}