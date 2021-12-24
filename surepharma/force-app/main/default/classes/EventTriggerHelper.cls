public class EventTriggerHelper {
    public static Map<Id,Contact> getEligibleChildContacts() {
        Id childRtId = ContactTriggerHelper.getContactRecordTypeId('Children');

        Contact[] contacts = [
            SELECT Id, Pediatrician__c, Stage__c, Phone, Patch_Applied_Datetime__c, Follow_Up_Datetime__c, Follow_Up_Eligible__c
            FROM Contact 
            WHERE RecordTypeId=:childRtId
        ];

        Map<Id,Contact> cMap = new Map<Id,Contact>();
        if (contacts.size() > 0) {
            for (Contact c: contacts) {
                cMap.put(c.Id, c);
            }
        }
        return cMap;
    }

    public static Map<Id,Account> getPediatricianAccounts() {
        Account[] accts = [SELECT Id, BillingAddress FROM Account WHERE Type='Pediatrician'];

        Map<Id,Account> aMap = new Map<Id,Account>();
        if (accts.size() > 0) {
            for (Account a: accts) {
                aMap.put(a.Id, a);
            }
        }
        return aMap;
    }
}
