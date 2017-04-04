/*
    Author: Matthew Rumschlag
    Repository: https://github.com/mjrforce/appirio-alexa-sf
    Description: An Amazon Intent that queries for Accounts of the logged in user.
*/
public class AlexaAccountInfoIntent extends AlexaIntent {

    public AlexaAccountInfoIntent() {
        //Give the Alexa Skill a name. This will be used in the skill schema.
        super('SFAccountInfo');
        
        //Define the slots to be used or variables inside of the utterances that launch our intent.
        //Reference: https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/built-in-intent-ref/slot-type-reference
        
        List < AlexaIntent.Slot > slots = new List < AlexaIntent.Slot > ();
        slots.add(new AlexaIntent.Slot('number', 'AMAZON.NUMBER'));
        
        //Define the utterances that launch our intent.
        //Reference: https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/defining-the-voice-interface#h2_sample_utterances
        
        List < String > utterances = new List < String > ();
        utterances.add('get my top {number} Accounts');
        utterances.add('get my top {number} Account');
        utterances.add('get {number} Accounts that belong to me');
        utterances.add('get {number} Account that belong to me');
        utterances.add('get {number} Accounts that belongs to me');
        utterances.add('get {number} Account that belongs to me');
        utterances.add('what are my top {number} Accounts');
        utterances.add('what are my top {number} Account');
        
        //Add the slots and utterances to the skill.
        this.setSlots(slots);
        this.setUtterances(utterances);
    }

    public override ASkillResponse execute(ASkillRequest request) {
        //Setup the SOAP call
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        //Get the alexa settings for constructing the URL.
        Alexa_Settings__c settings = Alexa_Settings__c.getorgdefaults();
        string baseURL = settings.base_Url__c;
        String endpoint = baseURL + '/services/Soap/c/34.0';
        
        //REST call stuff
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        req.setHeader('SOAPAction', 'getUserInfo');

        //Get the authorization token from the Alexa Request received from Amazon
        String authToken = request.session.user.accessToken;

        //Construct the body of the SOAP call to return the user information
        String soapBody = '<?xml version="1.0" encoding="utf-8"?>';
        soapBody += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">';
            soapBody += '<soapenv:Header>';
                soapBody += '<urn:SessionHeader>';
                    soapBody += '<urn:sessionId>' + authToken + '</urn:sessionId>'; 
                soapBody += '</urn:SessionHeader>';
            soapBody += '</soapenv:Header>';
            soapBody += '<soapenv:Body><urn:getUserInfo /></soapenv:Body>';
        soapBody += '</soapenv:Envelope>';

        //Set the body of the SOAP call
        req.setBody(soapBody);
        
        //Make the call
        HttpResponse resp = h.send(req);
        
        //Parse the response
        Dom.Document doc = resp.getBodyDocument();
        //Retrieve the root element for this document.
        Dom.XMLNode soapenvEnvelope = doc.getRootElement();
        String SOAPENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String NS = 'urn:enterprise.soap.sforce.com';
        Dom.XMLNode bodyNode = soapenvEnvelope.getChildElement('Body', SOAPENV_NS);
        Dom.XMLNode userinfoRespNode = bodyNode.getChildElement('getUserInfoResponse', NS);
        Dom.XMLNode resultNode = userinfoRespNode.getChildElement('result', NS);
        Dom.XMLNode userIdNode = resultNode.getChildElement('userId', NS);
        
        //Get the user id
        String userid = userIdNode.getText();

        //Get the value of the slot varriable from the Alexa Request
        string slotNumber = request.getSlot('number');
        
        //Construct the query
        string query = 'SELECT id, Name from Account where ownerid = :userId order by Name ASC limit ' + slotNumber;

        //Parse the query response
        list < string > names = new list < String > ();
        for (Account a: database.query(query))
            names.add(a.name);

        //Construct something for Alexa to say
        String responseText = 'Your ' + slotNumber + ' Accounts are ' + String.join(names, ',');
        
        //Say it Alexa!
        return this.say(responseText, 'My Top Accounts', responseText, null, true);

    }


}