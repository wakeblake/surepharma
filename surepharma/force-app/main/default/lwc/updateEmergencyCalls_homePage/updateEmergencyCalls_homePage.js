import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import clientHandler from '@salesforce/apex/EmergencyCallLogCallout.clientHandler';

export default class UpdateEmergencyCalls extends LightningElement {
    isExecuting = false;

    @api async handleClick() {
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

        this.isExecuting = false;
    }
}