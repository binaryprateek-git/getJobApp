/*
Sample Json Assumed:
{
"candidate": [
      {
	  "name":ABC
	  "email":abc@abc.com
	  "phone":7778904567
	  "jobId":R121
	  },
	  {
	  "name":XYZ
	  "email":xyz@xyz.com
	  "phone":777234567
	  "jobId":R121
	  },
	  {
	  "name":PQR
	  "email":pqr@pqr.com
	  "phone":7008904567
	  "jobId":R129
	  }
	 ]
}


*/

@RestResource(urlMapping='/web/jobs/*')
global without sharing class API_CreateJobApplication {
    @HttpPost
    global static jobApplicationResWrapper createJobApp() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        res.addHeader('Content-Type', 'application/json');
        Set<String> setOfAllCandidateEmails= new Set<String>();  //set of Email of All Candidate
        Set<String> setOfNewCandidateEmails= new Set<String>();  //set of only Emails of new candidates(new Contact)
        Map<String,String> mapOfEmailToContactId= new Map<String,String>(); //map of Email and contact id
        Map<String,String> mapOfEmailToJobId= new Map<String,String>(); //map of email and jobid
        
        jobApplicationResWrapper objResponse = new jobApplicationResWrapper();
        objResponse.status = 'SUCCESS';
        
        try {
            if(RestContext.request != null && RestContext.request.requestBody != null){
                String jsonstring=RestContext.request.requestBody.toString();
                Boolean error = false;
                List<CandidateParams> cpWrapperObject = (List<CandidateParams>) JSON.deserialize(jsonstring, CandidateParams.class); //desearlizing json
                
                for(CandidateParams cp: cpWrapperObject){
                    setOfAllCandidateEmails.add(cp.candidate.email);
                    mapOfEmailToJobId.put(cp.candidate.email,cp.candidate.jobId);
                }
                //checking if contacts already exist
                if(setOfAllCandidateEmails.size()>0){
                    List<Contact> lstOfOldContacts= [SELECT Id, Email From Contact where Email IN:setOfAllCandidateEmails];
                    if(lstOfOldContacts.size()>0){
                        for(Contact c: lstOfOldContacts){
                            mapOfEmailToContactId.put(c.Email,c.id);
                        }
                    }
                }

                //if contact doesnot exist create new contacts
                List<Contact> lstOfNewContacts = new List<Contact>();
                for(CandidateParams cp: cpWrapperObject){
                    if(!mapOfEmailToContactId.containsKey(cp.candidate.email)){
                        Contact conObject = new Contact();
                        conObject.LastName = cp.candidate.name;
                        conObject.Email = cp.candidate.email;
                        conObject.Phone = cp.candidate.phone;
                        lstOfNewContacts.add(conObject);
                        setOfNewCandidateEmails.add(cp.candidate.email);              
                    }
                }
                if(lstOfNewContacts.size()>0){
                    database.insert(lstOfNewContacts,false);
                    List<Contact> lstOfCon = [SELECT Id, Email From Contact where Email IN:setOfNewCandidateEmails];
                    if(lstOfCon.size()>0){
                        for(Contact c: lstOfCon){
                            mapOfEmailToContactId.put(c.Email,c.id);
                        }
                    }
                }
                
                //inserting the jobapplications records
                List<Job_Application__c> lstOfNewJobApplication = new List<Job_Application__c>();
                if(mapOfEmailToContactId.size()>0){
                    for(String s : mapOfEmailToContactId.keySet()){              
                        Job_Application__c jobAppObject = new Job_Application__c();
                        jobAppObject.Job__c= mapOfEmailToJobId.get(s);
                        jobAppObject.Contact__c = mapOfEmailToContactId.get(s);
                        jobAppObject.Active__c = true; //assuming the web teams only send the job applications for active jobs;
                        lstOfNewJobApplication.add(jobAppObject);
                    }
                    if(lstOfNewJobApplication.size()>0){
                        Database.SaveResult[] jobApplicationList = database.insert(lstOfNewJobApplication,false);
                        // Iterate through each returned result
                        for (Database.SaveResult ja : jobApplicationList) {
                            if (ja.isSuccess()) {
                                System.debug('Successfully inserted Job Application. Account ID: ' + ja.getId());
                                
                            }
                            else {
                                // Operation failed, so get all errors                
                                for(Database.Error err : ja.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Job Application fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                        objResponse.result = 'ABC';
                    }
                }                
            }                                   
        } catch(Exception e){
            objResponse.status = String.valueOf(e);
        }  
        //res.responseBody = Blob.valueOf(JSON.serialize(theResult));
        
        return objResponse;
    }

    public class CandidateParams {
        public Candidates candidate{get;set;}
    }
    
    public class Candidates {
        String name {get;set;}
        String email {get;set;}
        String phone {get;set;}
        String jobId {get;set;}
    }
    
    public class jobApplicationStatusWrapper {
        public String status;
        public String recordid;
    }
    
    global without sharing class jobApplicationResWrapper{
        public string status;
        public string result;        
    }
}