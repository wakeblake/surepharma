trigger EventTrigger on Event (before update, before insert, after insert, after update, after delete) {
    // TODO add checks for empty maps
    // TODO handle stage flow in separate class
    // TODO move logic to ContactTriggerHelper for testing

    Map<Id,Contact> cMap = EventTriggerHelper.getEligibleChildContacts();
    Map<Id,Account> aMap = EventTriggerHelper.getPediatricianAccounts();
    TimeZone tz = UserInfo.getTimeZone();
    List<Contact> contacts = new List<Contact>();

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Event e : Trigger.new) {
                Contact c = cMap.get(e.WhoId);

                Account a = aMap.get(c.Pediatrician__c);
                String location = 
                    a.BillingAddress.getStreet() + ', ' + 
                    a.BillingAddress.getCity() + ', ' + 
                    a.BillingAddress.getStateCode() + ' ' + 
                    a.BillingAddress.getPostalCode();
                    
                e.WhatId = c.Pediatrician__c;
                e.Location = location;
            }
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Event e : Trigger.new) {
                if (e.Type == 'Patch Application') {
                    Contact c = cMap.get(e.WhoId);
                    String stage = (c.Stage__c == 'Screening') ? 'Appointment' : c.Stage__c;
                    c.Patch_Applied_Datetime__c = e.ActivityDateTime;
                    c.Stage__c = stage;
                    contacts.add(c);

                } else if (e.Type == 'Follow Up') {
                    Contact c = cMap.get(e.WhoId);
                    c.Follow_Up_Datetime__c = e.ActivityDateTime;
                    contacts.add(c);
                }
                
            }
            
            if (!contacts.isEmpty()) {
                update contacts;
            }
        }

        if (Trigger.isDelete) {
            for (Event e : Trigger.old) {
                if (e.Type == 'Patch Application') {
                    Contact c = cMap.get(e.WhoId);
                    if (c.Stage__c == 'Screening' || c.Stage__c == 'Appointment') {
                        c.Stage__c = 'Appointment';
                        c.Patch_Applied_Datetime__c = null;
                        c.Follow_Up_Datetime__c = null;
                        c.Follow_Up_Eligible__c = false;
                        contacts.add(c);
                    }

                } else if (e.Type == 'Follow Up') {
                    Contact c = cMap.get(e.WhoId);
                    c.Follow_Up_Datetime__c = null;
                    contacts.add(c);
                }
            }

            if (!contacts.isEmpty()) {
                update contacts;
            }
        }
    }
}