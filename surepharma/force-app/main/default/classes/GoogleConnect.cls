public class GoogleConnect{
 
    
    public static void authorizeConnection() {      
       Auth.JWT jwt = new Auth.JWT();
       jwt.setSub('surepharma@surepharma.iam.gserviceaccount.com'); 
       jwt.setAud('https://oauth2.googleapis.com/token'); 
       jwt.setIss('surepharma@surepharma.iam.gserviceaccount.com');
       
       //Additional claims to set scope
       Map<String, Object> claims = new Map<String, Object>();
       claims.put('scope', 'https://www.googleapis.com/auth/spreadsheets');
           
       jwt.setAdditionalClaims(claims);

       //Create the object that signs the JWT bearer token
       Auth.JWS jws = new Auth.JWS(jwt, 'CertFromCertKeyManagement');
       
       //Get the resulting JWS in case debugging is required
       String token = jws.getCompactSerialization();
       
       //Set the token endpoint that the JWT bearer token is posted to
       String tokenEndpoint = 'https://oauth2.googleapis.com/token';
       
       //POST the JWT bearer token
       Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
       
       //Get the access token
       String accessToken = bearer.getAccessToken();

   }
}
