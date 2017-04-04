/*
    Author: Matthew Rumschlag
    Repository: https://github.com/mjrforce/appirio-alexa-sf
    Description: A Proxy between Salesforce Connected App and Amazon. Use VF page AlexaOAuthCallbackProxy as the connected apps callback url via sites.
*/
public class AlexaOAuthCallbackProxyController {

    public string getOnLoadAuthCode() {

        Alexa_Settings__c settings = Alexa_Settings__c.getOrgDefaults();

        if (settings.Auth_Code_Grant__c == true) {
            Map < String, String > params = apexPages.currentPage().getparameters();

            RestLog__c requestLog = new RestLog__c(Body__c = JSON.serializepretty(JSON.serializepretty(params)),
                Method__c = 'AlexaOAuthCallbackProxyController.getOnLoadAuthCode');

            try {

                string state = params.get('state');
                String key = state.substring(0, state.indexOf('-'));
                string returnstate = state.replace(key + '-', '');

                Alexa_Apps__c app = Alexa_Apps__c.getInstance(key);
                pagereference Page = new pagereference(app.callback_url__c);
                Page.getParameters().put('code', params.get('refresh_token'));
                Page.getParameters().put('state', returnstate);

                requestlog.Response__c = page.getURL();
                if (settings.enable_debug__c)
                    insert requestlog;
                return page.getURL();
            } catch (exception e) {
                requestlog.exception__c = e.getmessage();
                if (settings.enable_debug__c)
                    insert requestlog;
                return null;
            }
        } else {
            return null;
        }
    }
    @remoteaction
    public static string onLoadHash(string params) {

        //redirect uri configured in the Alexa Skill configuration
        Alexa_Settings__c settings = Alexa_Settings__c.getOrgDefaults();
        RestLog__c requestLog = new RestLog__c(Body__c = JSON.serializepretty(params),
            Method__c = 'AlexaOAuthCallbackProxyController.onLoadHash');

        try {
            system.debug(params);
            List < string > splitparams = params.split('&');
            system.debug(splitparams);
            map < string, string > mmap = new map < String, string > ();
            for (string s: splitparams) {
                mmap.put(s.substring(0, s.indexof('=')), s.substring(s.indexof('=') + 1));
            }
            string state = mmap.get('state');
            String key = state.substring(0, state.indexOf('-'));
            string returnstate = state.replace(key + '-', '');

            Alexa_Apps__c app = Alexa_Apps__c.getInstance(key);
            string url = app.callback_url__c;
            url += '#' + 'access_token=' + mmap.get('access_token');
            url += '&state=' + returnstate;
            url += '&token_type=Bearer';

            requestlog.Response__c = url;

            if (settings.enable_debug__c)
                insert requestlog;

            return url;

        } catch (exception e) {
            requestlog.exception__c = e.getmessage();
            if (settings.enable_debug__c)
                insert requestlog;
            return null;
        }

    }
}