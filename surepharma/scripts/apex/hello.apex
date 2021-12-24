
/*
List<Schema.RecordTypeInfo> contactRts = Contact.getSObjectType().getDescribe().getRecordTypeInfos();
for (Schema.RecordTypeInfo rt : contactRts) {
    if (rt.getName() == 'Adults') {
        system.debug(rt.getRecordTypeId());
    }
}
*/

/*
TimeZone tz = UserInfo.getTimeZone();
Event e = [SELECT Id, Subject, ActivityDate, ActivityDateTime, Location FROM Event LIMIT 1];
Datetime dt = e.ActivityDateTime.addHours(tz.getOffset(e.ActivityDateTime) / (1000 * 60 * 60));
system.debug(dt);
*/

//Map<String,Object> results = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
//List<Object> sheets = (List<Object>) results.get('sheets');
//Map<String,Object> data = (Map<String,Object>) sheets[0].get(data);

//EmergencyCall__c[] ecalls = [SELECT Id FROM EmergencyCall__c];
//delete ecalls;

//String value = EmergencyCallLogCallout.clientHandler();
//system.debug(value);

/*
List<String> accountNames = new List<String>{'Johansson-Jost','Sheeran-Seaborn','Bloom-Perry','Musk-Grimes','Diaz-Madden','Legend-Teigen','Rossdale-Stefani'};
List<String> pFirst = new List<String>{'Scarlett','Colin','Ed','Cherry','Katy','Orlando','Elon','','Cameron','Benji','Chrissy','John','Gwen','Gavin'};
List<String> pLast = new List<String>{'Johansson','Jost','Sheeran','Seaborn','Perry','Bloom','Musk','Grimes','Diaz','Madden','Teigen','Legend','Stefani','Rossdale'};
List<String> cFirst = new List<String>{'Cosmo','Lyra','Daisy','XAE','Raddix','Luna'};
List<String> cLast = new List<String>{'Johansson-Jost','Antarctica','Dove','A-12','Diaz-Madden','Simone'};
List<String> ggFirst = new List<String>{'Apollo','Kingston','Zuma'};
List<String> ggLast = new List<String>{'Flynn','McGregor','Rock'};

List<Account> accts = new List<Account>();
for (String name : accountNames) {
    Account a = new Account(
        Name = name,
        Type = 'Household'
    );
    accts.add(a);
}
insert accts;

Id adultRtId = ContactTriggerHelper.getContactRecordTypeId('Adults');
List<Contact> parents = new List<Contact>();
for (Integer i=0; i<pLast.size(); i++) {
    Contact c = new Contact(
        FirstName=pFirst[i],
        LastName=pLast[i],
        Primary_Contact__c = Math.mod(i,2) == 0 ? true : false,
        RecordTypeId = adultRtId
    );
    parents.add(c);
}
insert parents;

Id childRtId = ContactTriggerHelper.getContactRecordTypeId('Children');
List<Contact> kids = new List<Contact>();
for (Integer i=0; i<cLast.size(); i++) {
    Contact c = new Contact(
        FirstName = cFirst[i],
        LastName=cLast[i],
        Birthdate= Date.newInstance(2019,i+1,i+7),
        RecordTypeId = childRtId
    );
    kids.add(c);
}
insert kids;

Account fam = [SELECT Id FROM Account WHERE Name='Rossdale-Stefani'];
List<Contact> kids2 = new List<Contact>();
for (Integer i=0; i<ggLast.size(); i++) {
    Contact c = new Contact(
        FirstName = ggFirst[i],
        LastName=ggLast[i],
        Birthdate= Date.newInstance(2018,(i+2)*2,(i+3)*3),
        AccountId=fam.Id,
        RecordTypeId=childRtId
    );
    kids2.add(c);
}
insert kids2;
*/

Account ped = [SELECT Id FROM Account WHERE Name LIKE '%Paul%'];
Account parent = [SELECT Id,Name,Primary_Contact__c,Type FROM Account WHERE Name Like '%Jones%'];
Id adultRt = ContactTriggerHelper.getContactRecordTypeId('Adults');
Id childRt = ContactTriggerHelper.getContactRecordTypeId('Children');
Id healthRt = ContactTriggerHelper.getContactRecordTypeId('Health Professionals');

Contact c1 = new Contact(
    LastName='Trigger',
    FirstName='Bill',
    AccountId=parent.Id,
    RecordTypeId=childRt
);
upsert c1;

Contact p1 = new Contact(
    LastName='Trigger',
    FirstName='Ed',
    AccountId=parent.Id,
    RecordTypeId=adultRt
);
upsert p1;

Contact h1 = new Contact(
    LastName='Doctor',
    FirstName='Doctor',
    AccountId=ped.Id,
    RecordTypeId=healthRt
);
upsert h1;