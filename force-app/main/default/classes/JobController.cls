public with sharing class JobController {
    @AuraEnabled(cacheable=true)
    public static List<Job__c> getJobs(Id AccId){

        return [SELECT Id, Name,JobTitle__c FROM Job__c Where Department__c=:AccId AND Active__c=true];
        
    }
    public static List<Job__c> getJobsRelatedDetails(Id JobId){

        List<Job_Application__c> jobApp = [SELECT Id, Name, Contact__c FROM Job_Application__c Where Job__c=:JobId];
        return null;
        
    }
    
}