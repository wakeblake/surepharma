import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import clientHandler from '@salesforce/apex/EmergencyCallLogCallout.clientHandler';

export default class UpdateEmergencyCalls extends LightningElement {
    isExecuting = false;

    @api async invoke() {
        if (this.isExecuting) {
            return;
        }

        this.isExecuting = true;

        await clientHandler()
            .then( result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!',
                        message: 'Emergency Call records have been updated'
                    })
                )
            })
            .catch( error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Callout to Emergency Call service failed' + error
                    })
                )
            })
        /*    
        await this.updateCalls()
            .then( (success) => {this.dispatchEvent(success);})
            .catch( (e) => {this.dispatchEvent(e);})
        */
        this.isExecuting = false;
    }
    
    /*
    updateCalls() {
        var success = new ShowToastEvent({
            title: 'Success!',
            message: 'Emergency Call records have been updated'
        });

        var failure = new ShowToastEvent({
            title: 'Error',
            message: 'Callout to Emergency Call service failed'
        })
        
        return new Promise( (resolve, reject) => {
            var value = clientHandler();
            if (value == 'Success') {
                resolve(success);
            } else {
                reject(failure);
            }
            });
    }
    */
}