global class CampaignDeepCloner {

    @InvocableMethod(label='Clone Campaigns' description='Produces a list of cloned campaigns as sObjects' category='Campaign')
    public static List<CampaignCloneResult> cloneCampaigns(List<CampaignCloneRequest> request) {
        // Unwrap request with lists of campaigns from each tier
        List<Campaign> lstOriginalCampaigns = request.get(0).originalCampaigns;
        Date dateCampaignStartDate;
        Date dateCampaignEndDate;
    
        if (request.get(0).startDate != null) {
            dateCampaignStartDate = request.get(0).startDate;
        }
        if (request.get(0).endDate != null) {
            dateCampaignEndDate = request.get(0).endDate;
        }

        // Create empty list of campaigns to store clones to be returned
        List<Campaign> lstClonedCampaigns = new List<Campaign>();
        
        Map<Id, Campaign> mapOldCampaignToNew = new Map<Id, Campaign>();
        for (Campaign camp : lstOriginalCampaigns) {
            Campaign clonedCamp = camp.clone(false, true, false, false);
            mapOldCampaignToNew.put(camp.Id, clonedCamp);
        }

        try {
            insert mapOldCampaignToNew.values();
        } catch (exception ex) {
            System.debug('An exception occurred when trying to insert records: '  + ex.getMessage());
        }

        // Reparent cloned campaigns
        List<Campaign> lstCampaignsToUpdate = new List<Campaign>();
        for (Campaign c : mapOldCampaignToNew.values()) {
            if (mapOldCampaignToNew.get(c.ParentId) != null) {
                c.ParentId = mapOldCampaignToNew.get(c.ParentId).Id;
            }
            // Set start and end dates from input or one year back
            if (dateCampaignStartDate != null && dateCampaignEndDate != null) {
                c.StartDate = dateCampaignStartDate;
                c.EndDate   = dateCampaignEndDate;
            } else {
                c.StartDate = c.StartDate.addYears(1);
                c.EndDate   = c.EndDate.addYears(1);
            }
            
            lstCampaignsToUpdate.add(c);
        }
 
        try {
            update lstCampaignsToUpdate;
        } catch (exception ex) {
            System.debug('An exception occurred when trying to update records: '  + ex.getMessage());
        }
        
        // Parse output
        CampaignCloneResult result = new CampaignCloneResult();
        result.clonedCampaigns = lstCampaignsToUpdate;
        List<CampaignCloneResult> resultList = new List<CampaignCloneResult>();
        resultList.add(result);
        return resultList;

    }

    public class CampaignCloneRequest{

        @InvocableVariable(required=true)
        public List<Campaign> originalCampaigns;

        @InvocableVariable
        public Date startDate;

        @InvocableVariable
        public Date endDate;

    }
    
    public class CampaignCloneResult{

        @InvocableVariable
        public List<Campaign> clonedCampaigns;

    }
}