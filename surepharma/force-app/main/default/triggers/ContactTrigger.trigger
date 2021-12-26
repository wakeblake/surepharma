trigger ContactTrigger on Contact (before insert, before update) {
    // TODO add checks for empty maps
    // TODO handle stage flow in separate class
    // TODO move logic to ContactTriggerHelper for testing

    Id childRtId = ContactTriggerHelper.getContactRecordTypeId('Children');
    Map<Id,Account> hhAcctsMap = ContactTriggerHelper.getHouseholdAccounts();
    Map<Id,Account> pdAcctsMap = ContactTriggerHelper.getPediatricianAccounts();
    
    for (Contact c : Trigger.new) {
        if (c.RecordTypeId != childRtId) {
            Account a = pdAcctsMap.get(c.AccountId) == null ? hhAcctsMap.get(c.AccountId) : pdAcctsMap.get(c.AccountId);
            c.MailingStreet = a.BillingStreet;
            c.MailingCity = a.BillingCity;
            c.MailingState = a.BillingState;
            c.MailingPostalCode = a.BillingPostalCode;
            c.MailingCountry = a.BillingCountry;         
            c.Phone = a.Phone;
            c.OwnerId = a.OwnerId;
        }

        if (c.RecordTypeId == childRtId) {
            Account a = hhAcctsMap.get(c.AccountId);
            List<String> relatedAdults = new List<String>();
            if (a.Contacts.size() > 0) {
                for (Contact adult : a.Contacts) {
                    relatedAdults.add(adult.FirstName + ' ' + adult.LastName);
                }
            }
            Datetime now = Datetime.now();

            c.MailingStreet = a.BillingStreet;
            c.MailingCity = a.BillingCity;
            c.MailingState = a.BillingState;
            c.MailingPostalCode = a.BillingPostalCode;
            c.MailingCountry = a.BillingCountry;  
            c.Phone = a.Phone;
            c.OwnerId = a.OwnerId;
            
            c.Adults_In_Household__c = relatedAdults.size() > 0 ? String.join(relatedAdults, ', ') : '';

            if (c.Patch_Applied_Datetime__c < now) {
                c.Stage__c = 'Patch Applied';
            }
            
            if ( (c.Patch_Applied_Datetime__c != null) && (c.Patch_Applied_Datetime__c.addHours(48) < now) ) {
                c.Follow_Up_Eligible__c = true;
                c.Stage__c = 'Follow-Up';
            }

            if (c.Declined_Appointment__c == true) {
                c.Stage__c = 'Complete';
            }
        }
    }
}