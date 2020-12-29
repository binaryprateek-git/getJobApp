public with sharing class JobController {
    @AuraEnabled(cacheable=true)
    public static List<Job__c> getJobs(Id AccId){

        return [SELECT Id, Name,JobTitle__c FROM Job__c Where Department__c=:AccId AND Active__c=true];
        
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getJobsRelatedDetails(Id JobId){
        Map<String, String> mapOfJobApplicationtoContact = new Map<String, String>();
        List<Job_Application__c> lstOfJobApp = [SELECT Id, Name, Contact__r.Name FROM Job_Application__c Where Job__c=:JobId];
        if(lstOfJobApp.size()>0){
            for(Job_Application__c ja:lstOfJobApp){
                mapOfJobApplicationtoContact.put(ja.Name, ja.Contact__r.Name);
            }
        }
        return mapOfJobApplicationtoContact;
    }
    
}