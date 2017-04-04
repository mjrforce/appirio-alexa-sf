/*
    Author: Matthew Rumschlag
    Repository: https://github.com/mjrforce/appirio-alexa-sf
    Description: A proxy between Alexa and Salesforce for starting the OAuth process. Use AlexaOAuthStarter VF page as the Authorization URL in Alexa App settings in Amazon.
*/

public class AlexaOAuthStarterController {

    public PageReference onLoad(){
 
        Alexa_Settings__c settings = Alexa_Settings__c.getorgdefaults();
        string baseURL = settings.base_Url__c;      
        PageReference page = new PageReference(baseURL +'/services/oauth2/authorize');
        
        //Amazon gives two possible callback urls. The difference is the initial sub domain. Use this as a key and append to the start of the state.
        String alexaOauthCallbackURL = apexPages.currentPage().getparameters().get('redirect_uri');
        String key = alexaOauthCallbackURL.substring(alexaOauthCallbackURL.indexOfAnyBut('https://')-1, alexaOauthCallbackURL.indexOf('.'));
        
        page.getParameters().put('redirect_uri',settings.callback_proxy_url__c);
        page.getParameters().put('client_id', settings.client_id__c);
        page.getParameters().put('response_type', 'token');
        page.getParameters().put('state', key + '-' + apexPages.currentPage().getParameters().get('state'));
        
         RestLog__c requestLog = new RestLog__c(Body__c = JSON.serializepretty(apexpages.currentpage().getparameters()), 
                              Method__c = 'AlexaOAuthStarterController',
                              Response__c = page.getURL());
        if(settings.enable_debug__c)
          insert requestlog;
                              
        return page;
    }
}