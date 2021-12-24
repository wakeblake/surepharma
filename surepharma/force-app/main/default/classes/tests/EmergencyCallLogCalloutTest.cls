@isTest
private class EmergencyCallLogCalloutTest {
    @isTest
    public static void clientHandlerTest() {
        // Test different users
        User u = [SELECT Id, LastName FROM User WHERE LastName='Watson'];
        System.runAs(u) {
            // Set up CalloutMock
            //System.assert(resp.getBody() != null);
            //System.assert(resp.getStatusCode() == 200);
        }
    }
}
