/*
 * Created by Stefan Serkin on July 18, 2021
 * */

@isTest
public with sharing class CampaignDeepCloner_Test {

    @TestSetup
    static void setupData(){
        Integer intCampaignCount = 0;
        // Set amounts for each level
        Integer numCampaigns = 1;
        Integer numChildren = 2;
        Integer numGrandchildren = 2;
        Integer numGreatGrandchildren = 2;

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
    }

    @isTest
    static void testClone() {
        List<Campaign> lstOriginalCampaigns = [SELECT Id, Name, Status, Type, isActive, ParentId,
                                               		  StartDate, EndDate
                                                 FROM Campaign LIMIT 10000];

        Test.startTest();
        CampaignDeepCloner.CampaignCloneRequest request;
        request = new CampaignDeepCloner.CampaignCloneRequest();
        request.originalCampaigns = lstOriginalCampaigns;

        CampaignDeepCloner.cloneCampaigns(
            new List<CampaignDeepCloner.CampaignCloneRequest>{ request }
        );

        Test.stopTest();

        List<Campaign> lstCampaignsToVerify = [SELECT Id, Name FROM Campaign LIMIT 10000];

        if (lstCampaignsToVerify.size() <= 10000) {
            System.assertEquals(lstOriginalCampaigns.size()*2, lstCampaignsToVerify.size(), 'Unexpected amount of campaigns');
        }

    }

    @isTest
    static void testCloneWithCustomDates() {
        List<Campaign> lstOriginalCampaigns = [SELECT Id, Name, Status, Type, isActive, ParentId,
                                               		  StartDate, EndDate
                                                 FROM Campaign LIMIT 10000];

        Test.startTest();
        Date dateCmpStartDate = Date.today().addMonths(-11);
        Date dateCmpEndDate   = Date.today().addMonths(1);
        CampaignDeepCloner.CampaignCloneRequest request;
        request = new CampaignDeepCloner.CampaignCloneRequest();
        request.originalCampaigns = lstOriginalCampaigns;
        request.startDate         = dateCmpStartDate;
        request.endDate           = dateCmpEndDate;

        CampaignDeepCloner.cloneCampaigns(
            new List<CampaignDeepCloner.CampaignCloneRequest>{ request }
        );

        Test.stopTest();

        List<Campaign> lstCampaignsToVerify = [SELECT Id, Name FROM Campaign LIMIT 10000];

        if (lstCampaignsToVerify.size() <= 10000) {
            System.assertEquals(lstOriginalCampaigns.size()*2, lstCampaignsToVerify.size(), 'Unexpected amount of campaigns');
        }

    }

    @isTest
    static void testInvocableQueries() {
        Campaign primaryCampaign = [SELECT Id FROM Campaign WHERE ParentId = null LIMIT 1];
        List<Campaign> lstSecondaryCampaigns = [SELECT Id, ParentId 
                                                  FROM Campaign 
                                                 WHERE ParentId = :primaryCampaign.Id
                                                 LIMIT 10000];

        Set<Id> setParentCampaignIds = new Set<Id>();
        for (Campaign cmp : lstSecondaryCampaigns) {
            setParentCampaignIds.add(cmp.Id);
        }
        // Create request
        CampaignDeepCloneController.CampaignsRequest request;
        request = new CampaignDeepCloneController.CampaignsRequest();
        request.parentCampaigns = lstSecondaryCampaigns;
        List<Campaign> lstReturnedCampaigns = new List<Campaign>();
        // Create result
        CampaignDeepCloneController.CampaignsResult result;
        result = new CampaignDeepCloneController.CampaignsResult();
        List<CampaignDeepCloneController.CampaignsResult> lstResults = new List<CampaignDeepCloneController.CampaignsResult>{ result };
        lstResults = CampaignDeepCloneController.getChildCampaigns(
            new List<CampaignDeepCloneController.CampaignsRequest>{ request }
        );
        lstReturnedCampaigns = lstResults.get(0).childCampaigns;

        List<Campaign> lstCampaignsToVerify = [SELECT Id 
                                                 FROM Campaign 
                                                WHERE ParentId IN :setParentCampaignIds
                                                LIMIT 10000];
        
        System.assertEquals(lstCampaignsToVerify.size(), lstReturnedCampaigns.size(), 'Received unexpected amount of campaigns');

    }
}