/*
    Author: Matthew Rumschlag
    Repository: https://github.com/mjrforce/appirio-alexa-sf
    Description: A proxy between Amazon and Salesforce for fetching an access token from a refresh token.
*/
public class AlexaOAuthRefreshController{
    public PageReference onLoad(){
 
        Alexa_Settings__c settings = Alexa_Settings__c.getorgdefaults();
        string baseURL = settings.base_Url__c;      
        PageReference page = new PageReference(baseURL +'/services/oauth2/token');
        page.getParameters().put('grant_type','refresh_token');
        page.getParameters().put('client_id', settings.client_id__c);
        page.getParameters().put('client_secret', settings.client_secret__c);
        page.getParameters().put('state', apexPages.currentPage().getParameters().get('state'));
        return page;
    }
}