public class ContactTriggerHelper {
    public static Id getContactRecordTypeId(String name) {
        Id rtId;
        List<Schema.RecordTypeInfo> contactRts = Contact.getSObjectType().getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo rt : contactRts) {
            if (rt.getName() == name) {
                rtId = rt.getRecordTypeId();
            }
        }
        return rtId;
    }

    public static Map<Id,Account> getHouseholdAccounts() {
        Id adultRtId = getContactRecordTypeId('Adults');

        Account[] accts = [
            SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingAddress, Phone, OwnerId,
            (SELECT FirstName, LastName FROM Contacts WHERE RecordTypeId=:adultRtId)
            FROM Account WHERE Type='Household'
        ];

        Map<Id,Account> acctsMap = new Map<Id,Account>();
        if (accts.size() > 0) {
            for (Account a: accts) {
                acctsMap.put(a.Id, a);
            }
        }
        return acctsMap;
    }

    public static Map<Id,Account> getPediatricianAccounts() {
        Id hpRtId = getContactRecordTypeId('Health Professionals');

        Account[] accts = [
            SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingAddress, Phone, OwnerId,
            (SELECT FirstName, LastName FROM Contacts WHERE RecordTypeId=:hpRtId)
            FROM Account WHERE Type='Pediatrician'
        ];

        Map<Id,Account> acctsMap = new Map<Id,Account>();
        if (accts.size() > 0) {
            for (Account a: accts) {
                acctsMap.put(a.Id, a);
            }
        }
        return acctsMap;
    }
}
