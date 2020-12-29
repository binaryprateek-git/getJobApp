@isTest(SeeAllData=false)
private with sharing class API_CreateJobApplication_Test {
	private static final String WORKORDER_API_REQUESTURI = '/services/apexrest/web/jobs/';
	private static final String HTTPS_PROTOCOL = 'https://';
	private static final String METHOD_POST = 'POST';
	private static final String RESPONSE_SUCCESS = 'SUCCESS';
    
    static string createMockJsonReq(){
        String JsonbodyTerm = '{[{"name":"ABC","email":"abc@abc.com","phone":"7778904567","jobId":"R121"},{"name":"XYZ","email":"xyz@xyz.com","phone":"777234567","jobId":"R121"},{"name":"PQR","email":"pqr@pqr.com","phone":"7008904567","jobId":"R129"}]}';
    	
        return JsonbodyTerm;
    }
    
    @isTest
    static void testCreateJobApplication(){
        //system.runas(){
        RestRequest request = new RestRequest();
        String sfInstance = System.URL.getSalesforceBaseUrl().getHost();        
        request.requestUri = HTTPS_PROTOCOL + sfInstance + WORKORDER_API_REQUESTURI;
        request.httpMethod = METHOD_POST;
        String JSONString = createMockJsonReq();
        system.debug('JsonbodyTerm is'+JSONString);
        request.requestBody = Blob.valueOf(JSONString);
        RestContext.request = request;
        
        Test.startTest();
           API_CreateJobApplication.jobApplicationResWrapper objResponse = API_CreateJobApplication.createJobApp();    
        Test.stopTest();
        	system.assertEquals(RESPONSE_SUCCESS, objResponse.status);        
        //}
    }
}