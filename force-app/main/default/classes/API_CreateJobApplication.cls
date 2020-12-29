@RestResource(urlMapping='/web/cases/*')
global without sharing class API_CreateJobApplication {
    @HttpPost
    global static void createJobApp() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        Set<String> setOfAllCandidateEmails= new Set<String>();
        Set<String> setOfNewCandidateEmails= new Set<String>();
        Map<String,String> mapOfEmailToContactId= new Map<String,String>();
        Map<String,String> mapOfEmailToJobId= new Map<String,String>();
        Map<String,String> param2data = req.params;
        for(String s : param2data.keySet()){
            if(s=='email'){
                setOfAllCandidateEmails.add(param2data.get(s));
            }
        }
        res.addHeader('Content-Type', 'application/json');
        API_Result theResult = new API_Result();
        try {
            if(RestContext.request != null && RestContext.request.requestBody != null){
                String jsonstring=RestContext.request.requestBody.toString();
                Boolean error = false;
                CandidateParams cpWrapperObject = (CandidateParams) JSON.deserialize(jsonstring, CandidateParams.class);
                Contact conObject = new Contact();
                for(Contact c : [SELECT Id, Email From Contact where Email IN:setOfAllCandidateEmails]){
                    conObject = c;
                    //nullcheck;
                    if(!setOfAllCandidateEmails.contains(c.Email)){
                        setOfAllCandidateEmails.remove(c.Email);
                        setOfNewCandidateEmails.addAll(setOfAllCandidateEmails);
                    }
                    mapOfEmailToContactId.put(c.Email,c.id);
                }
                List<Contact> lstOfNewContacts = new List<Contact>();
                if(conObject.Id == null){
                    conObject.LastName = cpWrapperObject.name;
                    conObject.Email = cpWrapperObject.email;
                    conObject.Phone = cpWrapperObject.phone;
                    lstOfNewContacts.add(conObject);
                    //insert conObject;
                    //con = auth.createContact(unoId,false);                
                }
                Database.insert(lstOfNewContacts,false);
                List<Contact> lstOfCon = [SELECT Id, Email From Contact where Email IN:setOfNewCandidateEmails];
                //nullcheck
                for(Contact c: lstOfCon){
                    mapOfEmailToContactId.put(c.Email,c.id);
                }
                List<Job_Application__c> lstOfNewJobApplication = new List<Job_Application__c>();
                //null check
                for(String s : mapOfEmailToContactId.keySet()){              
                    Job_Application__c jobAppObject = new Job_Application__c();
                    jobAppObject.Job__c= mapOfEmailToJobId.get(s);
                    jobAppObject.Contact__c = mapOfEmailToContactId.get(s);
                    jobAppObject.Active__c = true; //assuming the web teams only send the job applications for active jobs;
                    lstOfNewJobApplication.add(jobAppObject);
                }
                //nullcheck
                database.insert(lstOfNewJobApplication,false);
            }                                   
        } catch(Exception e){
            res.statusCode = 500;
            theResult.error = String.valueOf(e);
        }  
        res.responseBody = Blob.valueOf(JSON.serialize(theResult));
    }

    public class CandidateParams {
        String name {get;set;}
        String email {get;set;}
        String phone {get;set;}
        String jobId {get;set;}
    }
}
