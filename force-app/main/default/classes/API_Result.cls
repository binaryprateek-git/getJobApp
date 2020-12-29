public with sharing class API_Result {
    public boolean success{
        get{
            return this.error == null;
        }
    }
    //public contact applicant {get; set;}
    public string error {get; set;}
}