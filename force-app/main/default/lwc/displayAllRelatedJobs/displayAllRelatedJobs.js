import { LightningElement, track, api } from 'lwc';
import getAllJobs from '@salesforce/apex/JobController.getJobs'

export default class DisplayAllRelatedJobs extends LightningElement{
    @api recordId;
    @track jobs;

    get responseReceived(){
        if(this.jobs){
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
    

}