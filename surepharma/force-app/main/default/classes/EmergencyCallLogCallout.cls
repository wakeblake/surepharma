public class EmergencyCallLogCallout {

    /* Deprecated this for server-server connection via GoogleConnect class 

    public static HttpResponse makeGetCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // TODO store some place
        String spreadsheetId = '1ByVvhND1weHo1pQLEhmXv5texOd_O_1n3r7HC2MOobg';

        // using Named Credential
        request.setEndpoint('callout:GoogleAPI/' + spreadsheetId + '/values/A1:Z1000?');  // grab entire sheet (would need to fix for larger datasets)
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            System.debug('Failed to return expected response: ' + response.getStatusCode());
        }

        return response;
    }
    */

    public static HttpResponse sendRequest() {
        String token = GoogleConnect.getAccessToken();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + token);
        String spreadsheetId = '1ByVvhND1weHo1pQLEhmXv5texOd_O_1n3r7HC2MOobg';
        req.setEndpoint('https://sheets.googleapis.com/v4/spreadsheets/' + spreadsheetId + '/values/A1:Z1000?');  // grab entire sheet (would need to fix for larger datasets)
        req.setMethod('GET');

        HttpResponse response = http.send(req);
        if (response.getStatusCode() != 200) {
            System.debug('Failed to return expected response: ' + response.getStatusCode());
        }

        return response;
    }

    public static void uploadEmergencyCalls(HttpResponse resp) {
        Map<String,Object> results = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> values = (List<Object>) results.get('values');
        List<Object> headers = (List<Object>) values[0];

        Map<String,Integer> fieldIndex = new Map<String,Integer>();
        for (Integer i=0; i < headers.size(); i++) {
            fieldIndex.put(
                (String) headers[i], i
            );
        }

        Id childRtId = ContactTriggerHelper.getContactRecordTypeId('Children');
        Map<Id,Id> cMap = new Map<Id,Id>();
        for (Contact c : [SELECT Id, OwnerId FROM Contact WHERE RecordTypeId=:childRtId]) {
            cMap.put(c.Id, c.OwnerId);
        }

        List<EmergencyCall__c> ecalls = new List<EmergencyCall__c>();
        for (Integer i=1; i < values.size(); i++) {
            List<Object> row = (List<Object>) values[i];
            String logId = (String) row[fieldIndex.get('Id')];
            Date eDate = Date.valueOf(
                (String) row[fieldIndex.get('Date')]
            );
            Id contactId = (String) row[fieldIndex.get('ContactId')];
            String description = (String) row[fieldIndex.get('Description')];

            EmergencyCall__c ec = new EmergencyCall__c(
                LogId__c = logId,
                Date__c = eDate,
                Contact__c = contactId,
                Description__c = description,
                OwnerId = cMap.get(contactId)
            );
            ecalls.add(ec);
        }

        upsert ecalls LogId__c;
    }

    @AuraEnabled
    public static String clientHandler() {
        String value = 'Success';
        try {
            HttpResponse resp = sendRequest();
            uploadEmergencyCalls(resp);
        } catch (Exception e) {
            value = e.getMessage();
        }
        return value;
    }
}
