import { LightningElement, track, api, wire } from 'lwc';
import getAllJobs from '@salesforce/apex/JobController.getJobs'
import getJobDetails from '@salesforce/apex/JobController.getJobsRelatedDetails'

export default class DisplayAllRelatedJobs extends LightningElement{
    @api recordId;
    jobs;
    jobdetails= [];
    jobId;
    isJobDetails =false;
    @track mapData= [];

    get responseReceived(){
        if(this.jobs){
            return true;
        }
        return false;
    }

    get jobDetailsReceived(){
        if(this.result){
            console.log('event 1'+isJobDetails);
            return true;
        }
        return false;
    }

    connectedCallback() {
        getAllJobs({AccId:this.recordId}).then(response =>{
            this.jobs = response;
        }).catch(error =>{
            console.error('Error in getting the Jobs', error.body.message);
        })
    }
    getApplications(event){
        this.jobId = event.target.dataset.recordId; 
        console.log('event 1'+jobId);
        
        
        }
    @wire(getJobDetails, {JobId:'$jobId'})
        wiredResult({result, error}){
            if (result) {
                isJobDetails=true;
                var conts = result.data;
                for(var key in conts){
                    this.mapData.push({value:conts[key], key:key}); //Here we are creating the array to show on UI.
                }
            }
            else if (error) {
                this.error = error;
                console.error('Error in getting the Jobs', error.body.message);
            }
        }
   
        /*getJobDetails({JobId:event.target.dataset.recordId}).then(response =>{
            this.jobdetails = response;
            console.error('jobdetails', jobdetails);
            /*var conts = jobdetails.data;
            for(var key in conts){
                this.mapData.push({value:conts[key], key:key});
            }
            console.error('mapData', mapData);*/

}