/*
 * Created by Stefan Serkin on July 18, 2021
 * */

global with sharing class CampaignDeepCloneController {
    
    @InvocableMethod(label='Get Child Campaigns' description='Returns the list of child campaigns for a list of parents' category='Campaign')
    public static List<CampaignsResult> getChildCampaigns(List<CampaignsRequest> request) {
        List<Campaign> lstParentCampaigns = request.get(0).parentCampaigns;

        Set<Id> setParentCampaignIds = new Set<Id>();
        for (Campaign cmp : lstParentCampaigns) {
            setParentCampaignIds.add(cmp.Id);
        }

        List<Campaign> lstChildCampaigns = [SELECT Id, Name, ParentId, StartDate, EndDate,
                                                      Status, Type, isCampaignSetup__c,
                                                      IsActive, RecordTypeId
                                                 FROM Campaign 
                                                WHERE ParentId IN :setParentCampaignIds
                                                LIMIT 10000];
        
        // Parse output
        CampaignsResult result = new CampaignsResult();
        result.childCampaigns = lstChildCampaigns;
        List<CampaignsResult> resultList = new List<CampaignsResult>();
        resultList.add(result);
        return resultList;
        
    }

    public class CampaignsRequest{
        
        @InvocableVariable
        public List<Campaign> parentCampaigns;

    }
    
    public class CampaignsResult{

        @InvocableVariable
        public List<Campaign> childCampaigns;

    }


}