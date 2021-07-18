public with sharing class CampaignSetup {

    public static void addCampaigns(Integer numCampaigns, 
                                    Integer numChildren, 
                                    Integer numGrandchildren, 
                                    Integer numGreatGrandchildren) 
    {
        Integer intCampaignCount = 0;
        // Set annual campaign to end on the final day of the current month
        Date cmpStartDate = Date.newInstance(Date.today().year() - 1, Date.today().month() + 1, 1);
        Date cmpEndDate   = Date.newInstance(Date.today().year(), Date.today().month(), Date.newInstance(Date.today().year(), Date.today().month() + 1, 1).addDays(-1).day());
		
        List<Campaign> lstPrimaryCampaigns = new List<Campaign>();
        for (Integer i = 0; i < numCampaigns; i++) {
            Campaign cmp = new Campaign();
            cmp.Name               = 'Massive Top-Level Campaign ' + String.valueOf(i);
            cmp.StartDate          = cmpStartDate;
            cmp.EndDate            = cmpEndDate;
            cmp.IsActive           = true;
            cmp.Status             = 'In Progress';
            cmp.Type               = 'Email';
            cmp.isCampaignSetup__c = true;
            lstPrimaryCampaigns.add(cmp);
        }
        if (!lstPrimaryCampaigns.isEmpty()) {
            insert lstPrimaryCampaigns;
            intCampaignCount += lstPrimaryCampaigns.size();
        }
        
        List<Campaign> lstSecondaryCampaigns = new List<Campaign>();
        Integer secondaryCmpCount = 0;
        for (Campaign cmpParent : lstPrimaryCampaigns) {
            for (Integer i = 0; i < numChildren; i++) {
                Campaign cm = new Campaign();
                cm.Name               = 'Slightly Less Massive Campaign ' + String.valueOf(secondaryCmpCount);
                cm.StartDate          = cmpStartDate;
                cm.EndDate            = cmpEndDate;
                cm.IsActive           = true;
                cm.Status             = 'In Progress';
                cm.Type               = 'Email';
                cm.ParentId           = cmpParent.Id;
                cm.isCampaignSetup__c = true;
                lstSecondaryCampaigns.add(cm);
                secondaryCmpCount++;
            }
        }
        if (!lstSecondaryCampaigns.isEmpty()) {
            insert lstSecondaryCampaigns;
            intCampaignCount += lstSecondaryCampaigns.size();
        }
        
        List<Campaign> lstTertiaryCampaigns = new List<Campaign>();
        Integer tertiaryCmpCount = 0;
        for (Campaign cmpParent : lstSecondaryCampaigns) {
            for (Integer i = 0; i < numGrandchildren; i++) {
                Campaign cm = new Campaign();
                cm.Name               = 'Pretty Small Campaign ' + String.valueOf(tertiaryCmpCount);
                cm.StartDate          = cmpStartDate;
                cm.EndDate            = cmpEndDate;
                cm.IsActive           = true;
                cm.Status             = 'In Progress';
                cm.Type               = 'Email';
                cm.ParentId           = cmpParent.Id;
                cm.isCampaignSetup__c = true;
                lstTertiaryCampaigns.add(cm);
                tertiaryCmpCount++;
            }
        }
        if (!lstTertiaryCampaigns.isEmpty()) {
            insert lstTertiaryCampaigns;
            intCampaignCount += lstTertiaryCampaigns.size();
        }
        
        List<Campaign> lstQuaternaryCampaigns = new List<Campaign>();
        Integer quaternaryCmpCount = 0;
        for (Campaign cmpParent : lstTertiaryCampaigns) {
            for (Integer i = 0; i < numGreatGrandchildren; i++) {
                Campaign cm = new Campaign();
                cm.Name               = 'Tiny Little Campaign ' + String.valueOf(quaternaryCmpCount);
                cm.StartDate          = cmpStartDate;
                cm.EndDate            = cmpEndDate;
                cm.IsActive           = true;
                cm.Status             = 'In Progress';
                cm.Type               = 'Email';
                cm.ParentId           = cmpParent.Id;
                cm.isCampaignSetup__c = true;
                lstQuaternaryCampaigns.add(cm);
                quaternaryCmpCount++;
            }
        }
        if (!lstQuaternaryCampaigns.isEmpty()) {
            insert lstQuaternaryCampaigns;
            intCampaignCount += lstQuaternaryCampaigns.size();
        }
        
        System.debug('Total amount of campaigns created: ' + intCampaignCount);
        
    }
    
    public static void deleteCampaigns() {
        for (List<Campaign> lstCampaignsToDelete : [SELECT Id FROM Campaign WHERE isCampaignSetup__c = true])
        {
            try {
            	delete lstCampaignsToDelete;
            } catch (dmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
    }


}