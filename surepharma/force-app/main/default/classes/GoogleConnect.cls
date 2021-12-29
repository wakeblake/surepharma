public class GoogleConnect {
    private final static String AUTH_ENDPOINT = 'https://oauth2.googleapis.com/token'; //'https://www.googleapis.com/oauth2/v4/token'; //
    private final static String SCOPE = 'https://www.googleapis.com/auth/spreadsheets';
    private final static String CACHE_ACCESS_TOKEN_KEY = 'googleCloudAccessToken';
    private final static String ISS = 'surepharma@surepharma.iam.gserviceaccount.com';
    
    public static String getAccessToken() {    
        String cachedAccessToken = (String) Cache.Org.get(CACHE_ACCESS_TOKEN_KEY);

        if (cachedAccessToken != null) {
            System.debug('Returning cached access token');
            return cachedAccessToken;

        } else {
            System.debug('No cached access token exists. Fetching a new one.');
            Auth.JWT jwt = new Auth.JWT();
            jwt.setSub('surepharma@surepharma.iam.gserviceaccount.com'); 
            jwt.setAud(AUTH_ENDPOINT); 
            jwt.setIss(ISS);
            
            //Additional claims to set scope
            Map<String, Object> claims = new Map<String, Object>();
            claims.put('scope', SCOPE);
                
            jwt.setAdditionalClaims(claims);
    
            //Create the object that signs the JWT bearer token with the certificate
            Auth.JWS jws = new Auth.JWS(jwt, 'google_cloud');

            // POST the JWT bearer token.  Will throw a Auth.JWTBearerTokenExchange.​JWTBearerTokenExchangeException​ with the error in the message if
            // the API fails to return the access token, the response is not in JSON format, or if the API returns a non-200 response code.
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(AUTH_ENDPOINT, jws);

            // Get the access token
            String token = bearer.getAccessToken();

            cacheAccessToken(token);

            return token;
        }
    }

    /**
     * Caches an access token in org cache so future API requests don't need to get a new token.
     * Compared to using Custom Settings, updating the org cache doesn't require a DML operation
     * and can be interleaved between callouts. The cache also handles expiration for us.
     */

    private static void cacheAccessToken(String accessToken) {
        // Cache the access token in the default org cache with a total of 30 seconds less than its expiration
        Cache.Org.put(CACHE_ACCESS_TOKEN_KEY, accessToken, 3600 - 30);
    }

    /**
     * Proactively clear the access token from the Custom Settings cache.
     * This won't invalidate the previous access token on Google's side, but it will remove it from
     * our cache so that future requests will be forced to fetch a new token.
     */

    public static Boolean clearAccessToken() {
        return Cache.Org.remove(CACHE_ACCESS_TOKEN_KEY);
    }

    public static HttpResponse sendRequest() {
        String token = getAccessToken();
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

    @AuraEnabled
    public static String clientHandler() {
        String value = 'Success';
        try {
            HttpResponse resp = sendRequest();
            EmergencyCallLogCallout.uploadEmergencyCalls(resp);
        } catch (Exception e) {
            value = e.getMessage();
        }
        return value;
    }
}
