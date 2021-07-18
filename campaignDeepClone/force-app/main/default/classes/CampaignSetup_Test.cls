/*
 * Created by Stefan Serkin on July 18, 2021
 * */

@isTest
public class CampaignSetup_Test {
    
    @isTest
    static void testCampaignSetup() {
        Integer intNumPrimaryCampaigns = 1;
        Integer intNumSecondaryCampaigns = 2;
        Integer intNumTertiaryCampaigns = 2;
        Integer intNumQuaternaryCampaigns = 2;

        Integer intTotalCampaigns = intNumPrimaryCampaigns + 
            (intNumPrimaryCampaigns * intNumSecondaryCampaigns) +
            (intNumPrimaryCampaigns * intNumSecondaryCampaigns * intNumTertiaryCampaigns) +
            (intNumPrimaryCampaigns * intNumSecondaryCampaigns * intNumTertiaryCampaigns * intNumQuaternaryCampaigns);

        Test.startTest();
        CampaignSetup.addCampaigns(intNumPrimaryCampaigns, intNumSecondaryCampaigns, intNumTertiaryCampaigns, intNumQuaternaryCampaigns);
        Test.stopTest();

        List<Campaign> lstCampaignsToVerify = [SELECT Id FROM Campaign LIMIT 10000];

        System.assertEquals(intTotalCampaigns, 
            lstCampaignsToVerify.size(), 
            'Received unexpected number of campaigns');

    }

    @isTest
    static void testDeleteCampaigns() {
        List<Campaign> lstOriginalCampaigns = [SELECT Id, isCampaignSetup__c FROM Campaign WHERE isCampaignSetup__c = true LIMIT 10000];

        Test.startTest();
        CampaignSetup.deleteCampaigns();
        Test.stopTest();

        List<Campaign> lstCampaignsToVerify = [SELECT Id, isCampaignSetup__c FROM Campaign WHERE isCampaignSetup__c = true LIMIT 10000];

        System.assertEquals(true, lstCampaignsToVerify.isEmpty(), 'Still received setup campaigns');

    }
}