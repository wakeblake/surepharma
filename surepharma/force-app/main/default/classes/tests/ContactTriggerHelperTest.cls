@isTest
private class ContactTriggerHelperTest {
    @testSetup static void setup() {
        Account a = new Account(
            Name='AccountHousehold',
            Type='Household',
            Phone='1002003000',
            BillingStreet='123 Fake St',
            BillingCity='Fake City',
            BillingState='Georgia',
            BillingCountry='United States',
            BillingPostalCode='30317'
        );
        insert a;

        Id adultRtId = ContactTriggerHelper.getContactRecordTypeId('Adults');
        Contact adult = new Contact(
            AccountId = a.Id,
            LastName = 'AccountHousehold',
            FirstName = 'Mom',
            RecordTypeId = adultRtId
        );
        insert adult;

        Id childRtId = ContactTriggerHelper.getContactRecordTypeId('Children');
        List<Contact> children = new List<Contact>();
        for (Integer i=0; i < 2; i++) {
            Contact c = new Contact(
                AccountId = a.Id,
                LastName='AccountHousehold',
                FirstName='Child' + i,
                Stage__c='Screening',
                RecordTypeId = childRtId
            );
            children.add(c);
        }
        insert children;
    }

    @isTest
    static void getHouseholdAccountsPositiveTest() {
        Map<Id,Account> aMap = ContactTriggerHelper.getHouseholdAccounts();
        System.assert(!aMap.isEmpty());

        for (Account a : aMap.values()) {
            String fname;
            for (Contact c : a.Contacts) {
                fname = c.FirstName;
            }
            System.assertEquals('1002003000', a.Phone);
            System.assertEquals('123 Fake St', a.BillingStreet);
            System.assertEquals('Georgia', a.BillingState);
            System.assertEquals('Mom', fname);
        }
    }
}
