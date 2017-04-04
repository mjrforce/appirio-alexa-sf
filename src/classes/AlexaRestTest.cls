/*
    Author: Matthew Rumschlag
    Repository: https://github.com/mjrforce/appirio-alexa-sf
    Description: An Amazon Intent that queries for Accounts of the logged in user.
*/

//This REST class should be set as public on your site profile.
//Implements GET and POST request creating a new skill.
//The service URL will be: [https://your_site_url/services/apexrest/AlexaRestTest]
//Uses the AlexaSkillRESTApp class that handle the methods

@RestResource(urlMapping='/AlexaRestTest/*')
global class AlexaRestTest {
    
    //This get request will help you get the schema and utterances for setup on the Amazon side.
    @HttpGet
    global static void get(){
        AlexaSkillRESTApp.handleGet(createAlexaSkill());
    }
    
    //This is the actual service.
    @HttpPost
    global static void post(){
        AlexaSkillRESTApp.handlePost(createAlexaSkill());
    }
    
    //Creates a new Skill
    private static AlexaSkill createAlexaSkill(){
        
        //Initialize the skill
        AlexaSkill skill = new AlexaSkill();
        
        //Set the application id from the custom settings
        Alexa_Settings__c settings =    Alexa_Settings__c.getOrgDefaults();
        skill.setApplicationId(settings.application_id__c);
        
        //Add all intents
        skill.addIntent(new AlexaUserInfoIntent());
        skill.addIntent(new AlexaAccountInfoIntent());
        skill.addIntent(new AlexaForceHelpIntent());
        skill.addIntent(new AlexaActivityInfoIntent());
        skill.addIntent(new AlexaRedAccountInfoIntent());
        
        //This is the intent launched when you say 'Alexa, Open My App'
        skill.addOnLaunchIntent(new AlexaForceHelpIntent());
        return skill;
    }

}