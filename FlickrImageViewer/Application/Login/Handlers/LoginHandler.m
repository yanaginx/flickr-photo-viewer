//
//  LoginHandler.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

#import "LoginHandler.h"

#import "../../../Common/Utilities/TDOAuth/TDOAuth.h"
#import "../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../Common/Utilities/Scope/Scope.h"
#import "../../../Common/Constants/Constants.h"

#import "../../../Common/Utilities/AccountManager/AccountManager.h"


@interface LoginHandler () {
    NSString *kRequestTokenPath;
    NSString *kAccessTokenPath;
    NSString *oauthToken;
    NSString *oauthTokenSecret;
    NSString *oauthVerifier;
    NSString *oauthAuthorizationURL;
    NSString *userNSID;
    NSString *accessToken;
    NSString *secretToken;
}

- (NSURLRequest *)requestTokenURLRequest;
- (NSURLRequest *)accessTokenURLRequestFromOAuthToken:(NSString *)request_token
                                     OAuthTokenSecret:(NSString *)request_token_secret
                                        OAuthVerifier:(NSString *)verifier;
- (NSURL *)authorizationURLFromOAuthToken:(NSString *)request_token;

@end

@implementation LoginHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize ivar
        kRequestTokenPath = @"/request_token";
        kAccessTokenPath = @"/access_token";
        
        oauthToken = @"";
        oauthTokenSecret = @"";
        oauthVerifier = @"";
        oauthAuthorizationURL = @"";
        userNSID = @"";
        accessToken = @"";
        secretToken = @"";
    }
    return self;
}

static AuthenticationState currentState = GettingRequestToken;

#pragma mark - Operations

- (void)startAuthenticationProcess {
    switch (currentState) {
        case GettingRequestToken:
            [self getRequestToken];
            NSLog(@"[DEBUG] %s : currentState: GettingRequestToken", __func__);
            break;
        case GettingAuthorization:
            [self getAuthorization];
            NSLog(@"[DEBUG] %s : currentState: GettingAuthorization", __func__);
            break;
        case GettingAccessToken:
            // Get the access token
            [self getAccessToken];
            NSLog(@"[DEBUG] %s : currentState: GettingAccessToken", __func__);
            break;
        case SavingUserInfo:
            [self saveUserInfo];
            NSLog(@"[DEBUG] %s: currentState: SavingUserInfo", __func__);
            break;
        default:
            break;
    }
}

- (void)getRequestToken {
    if (currentState != GettingRequestToken) {
        NSLog(@"[ERROR] %s : NOT CORRECT STATE", __func__);
        return;
    }
    NSURLRequest *request = [self requestTokenURLRequest];
    @weakify(self)
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error) {
        @strongify(self)
        if (error) {
            NSLog(@"[ERROR] %s : error: %@",
                  __func__,
                  error.localizedDescription);
            [self.delegate onFinishGettingRequestTokenWithErrorCode:LoginHandlerErrorNotValidData];
            [self resetVariables];
            return;
        }
        if (!data) {
            [self.delegate onFinishGettingRequestTokenWithErrorCode:LoginHandlerErrorNotValidData];
            [self resetVariables];
            return;
        }
        NSString *responseDataString = [[NSString alloc] initWithData:data
                                                             encoding:NSASCIIStringEncoding];
        if (![self isValidRequestTokenResponse:responseDataString]) {
            [self.delegate onFinishGettingRequestTokenWithErrorCode:LoginHandlerErrorNotValidData];
            [self resetVariables];
            return;
        }
        NSLog(@"[DEBUG] %s : request access token response: %@", __func__, responseDataString);
        
        BOOL isTokenAndSecretParsed = [self isParseRequestTokenAndSecretSuccessfulFromQuery:responseDataString];
        if (!isTokenAndSecretParsed) {
            [self.delegate onFinishGettingRequestTokenWithErrorCode:LoginHandlerErrorNotValidData];
            [self resetVariables];
            return;
        }
        
        NSLog(@"[DEBUG] %s : token parsed: %@, token secret parsed: %@",
              __func__,
              self->oauthToken,
              self->oauthTokenSecret);
        // Confirm there is no error
        [self.delegate onFinishGettingRequestTokenWithErrorCode:LoginHandlerNoError];
        // Changing state
        currentState = GettingAuthorization;
        [self startAuthenticationProcess];
    }] resume];
}

- (void)getAuthorization {
    if (currentState != GettingAuthorization ||
        [oauthToken isEqualToString:@""]) {
        NSLog(@"[ERROR] %s : NOT CORRECT STATE OR NOT SUFFICENT INFO", __func__);
        return;
    }
    NSURL *authorizationURL = [self authorizationURLFromOAuthToken:oauthToken];
    ASWebAuthenticationSession *authSession = [self authSessionWithAuthorizationURL:authorizationURL
                                                                  callbackURLScheme:kCallbackURLScheme];
    // start the authorization session in view
    [self.delegate requestAuthorizationUsingAuthSession:authSession];
}

- (void)getAccessToken {
    if (currentState != GettingAccessToken ||
        [oauthToken isEqualToString:@""] ||
        [oauthTokenSecret isEqualToString:@""] ||
        [oauthVerifier isEqualToString:@""]) {
        NSLog(@"[ERROR] %s : NOT CORRECT STATE OR NOT SUFFICENT INFO", __func__);
        return;
    }
    NSURLRequest *request = [self accessTokenURLRequestFromOAuthToken:oauthToken
                                                     OAuthTokenSecret:oauthTokenSecret
                                                        OAuthVerifier:oauthVerifier];
    @weakify(self)
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error) {
        @strongify(self)
        if (error) {
            NSLog(@"[ERROR] %s : error: %@",
                  __func__,
                  error.localizedDescription);
            [self.delegate onFinishGettingAccessTokenWithErrorCode:LoginHandlerErrorNotValidData];
            [self resetVariables];
            currentState = GettingRequestToken;
            return;
        }
        if (!data) {
            [self.delegate onFinishGettingAccessTokenWithErrorCode:LoginHandlerErrorServerError];
            [self resetVariables];
            currentState = GettingRequestToken;
            return;
        }
        NSString *responseDataString = [[NSString alloc] initWithData:data
                                                             encoding:NSASCIIStringEncoding];
        if (![self isValidAccessTokenResponse:responseDataString]) {
            [self.delegate onFinishGettingAccessTokenWithErrorCode:LoginHandlerErrorNotValidData];
            [self resetVariables];
            currentState = GettingRequestToken;
            return;
        }
        NSLog(@"[DEBUG] %s : request access token response: %@", __func__, responseDataString);
        
        BOOL isTokenAndSecretParsed = [self isParseAccessTokenAndSecretSuccessfulFromQuery:responseDataString];
        if (!isTokenAndSecretParsed) {
            [self.delegate onFinishGettingAccessTokenWithErrorCode:LoginHandlerErrorNotValidData];
            [self resetVariables];
            currentState = GettingRequestToken;
            return;
        }
        
        NSLog(@"[DEBUG] %s : token parsed: %@, token secret parsed: %@",
              __func__,
              self->accessToken,
              self->secretToken);
        // Confirm there is no error
        [self.delegate onFinishGettingAccessTokenWithErrorCode:LoginHandlerNoError];
        // Changing state
        currentState = SavingUserInfo;
        [self startAuthenticationProcess];
    }] resume];
}

- (void)saveUserInfo {
    if (currentState != SavingUserInfo ||
        [userNSID isEqualToString:@""] ||
        [accessToken isEqualToString:@""] ||
        [secretToken isEqualToString:@""]) {
        NSLog(@"[ERROR] %s : NOT CORRECT STATE OR NOT SUFFICENT INFO", __func__);
        return;
    }
    [AccountManager setAccountInfoWithUserNSID:userNSID
                               userAccessToken:accessToken
                               userSecretToken:secretToken];
    if (!AccountManager.isUserInfoSetSuccessful) {
        [self.delegate onFinishSavingUserInfo:LoginHandlerErrorNotValidData];
        currentState = GettingRequestToken;
        [self resetVariables];
        return;
    }
    // Changing state
    currentState = GettingRequestToken;
    [self.delegate onFinishSavingUserInfo:LoginHandlerNoError];
}


#pragma mark - Token URL & URLRequest

- (NSURLRequest *)requestTokenURLRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kCallbackURL forKey:@"oauth_callback"];
        
    NSURLRequest *request = [OAuth URLRequestForPath:kRequestTokenPath
                                       GETParameters:params
                                              scheme:@"https"
                                                host:kOAuthHost
                                         consumerKey:kConsumerKey
                                      consumerSecret:kConsumerSecret
                                         accessToken:nil
                                         tokenSecret:nil];
    return request;
}

- (NSURL *)authorizationURLFromOAuthToken:(NSString *)oauthToken {
    NSString *authorizationURLString = [NSString stringWithFormat:@"%@?oauth_token=%@&perms=read&perms=write",
                                                                    kAuthorizationEndpoint,
                                                                    oauthToken];
    
    return [NSURL URLWithString:authorizationURLString];
}

- (NSURLRequest *)accessTokenURLRequestFromOAuthToken:(NSString *)requestToken
                                     OAuthTokenSecret:(NSString *)requestTokenSecret
                                        OAuthVerifier:(NSString *)verifier {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kCallbackURL forKey:@"oauth_callback"];
    [params setObject:verifier forKey:@"oauth_verifier"];
    

    NSURLRequest *request = [OAuth URLRequestForPath:kAccessTokenPath
                                       GETParameters:params
                                              scheme:@"https"
                                                host:kOAuthHost
                                         consumerKey:kConsumerKey
                                      consumerSecret:kConsumerSecret
                                         accessToken:requestToken
                                         tokenSecret:requestTokenSecret];
    return request;
}


- (NSURLRequest *)accessTokenURLRequest {
    NSString *requestAccessToken = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token"];
    NSString *requestTokenSecret = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token_secret"];
    NSString *requestVerifier = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_verifier"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kCallbackURL forKey:@"oauth_callback"];
    [params setObject:requestVerifier forKey:@"oauth_verifier"];
    

    NSURLRequest *request = [OAuth URLRequestForPath:kAccessTokenPath
                                       GETParameters:params
                                              scheme:@"https"
                                                host:kOAuthHost
                                         consumerKey:kConsumerKey
                                      consumerSecret:kConsumerSecret
                                         accessToken:requestAccessToken
                                         tokenSecret:requestTokenSecret];
    return request;
}

- (NSString *)userAccessToken {
    return [NSUserDefaults.standardUserDefaults stringForKey:@"user_oauth_token"];
}

- (NSString *)userTokenSecret {
    return [NSUserDefaults.standardUserDefaults stringForKey:@"user_oauth_token_secret"];
}

- (NSString *)userNSID {
    return [NSUserDefaults.standardUserDefaults stringForKey:@"user_nsid"];
}

- (NSURL *)authorizationURL {
    NSString *requestOAuthToken = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token"];
    NSString *requestOAuthTokenSecret = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token_secret"];
    if (!requestOAuthToken || !requestOAuthTokenSecret) return nil;
    
    NSString *authorizationURLString = [NSString stringWithFormat:@"%@?oauth_token=%@&perms=read&perms=write",
                                                                    kAuthorizationEndpoint,
                                                                    requestOAuthToken];
    
    return [NSURL URLWithString:authorizationURLString];
}

- (NSString *)callbackURLScheme {
    return @"flickrz";
}

#pragma mark - Authorization Session
- (ASWebAuthenticationSession *)authSessionWithAuthorizationURL:(NSURL *)authorizationURL
                                              callbackURLScheme:(NSString *)URLScheme {
    @weakify(self)
    ASWebAuthenticationSession *session = [[ASWebAuthenticationSession alloc] initWithURL:authorizationURL
                                                                        callbackURLScheme:URLScheme
                                                                        completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        @strongify(self)
        if (error) {
            NSLog(@"[ERROR] %s : error: %@",
                  __func__,
                  error.localizedDescription);
            [self.delegate onFinishGettingAuthorizationWithErrorCode:LoginHandlerErrorNotValidData];
            currentState = GettingRequestToken;
            [self resetVariables];
            return;
        }
        if (callbackURL == nil) {
            [self.delegate onFinishGettingAuthorizationWithErrorCode:LoginHandlerErrorNetworkError];
            currentState = GettingRequestToken;
            [self resetVariables];
            return;
        }
        
        NSLog(@"[DEBUG] %s: url: %@", __func__, !callbackURL.baseURL ? @"No base URL" : callbackURL.baseURL.absoluteString);
        NSLog(@"[DEBUG] %s: url query: %@", __func__, !callbackURL.query ? @"No query string" : callbackURL.query);
        
        if (![self isValidAuthorizationResponse:callbackURL.query]) {
            [self.delegate onFinishGettingAuthorizationWithErrorCode:LoginHandlerErrorNotValidData];
            currentState = GettingRequestToken;
            [self resetVariables];
            return;
        }
        
        BOOL isTokenAndVerifierParsed = [self isParseTokenAndVerifierSuccessfulFromQuery:callbackURL.query];
        if (!isTokenAndVerifierParsed) {
            [self.delegate onFinishGettingAuthorizationWithErrorCode:LoginHandlerErrorNotValidData];
            currentState = GettingRequestToken;
            [self resetVariables];
            return;
        }
        NSLog(@"[DEBUG] %s : token parsed: %@, verifier parsed: %@",
              __func__,
              self->oauthToken,
              self->oauthVerifier);
        // Confirm there is no error
        [self.delegate onFinishGettingAuthorizationWithErrorCode:LoginHandlerNoError];
        // Changing state
        currentState = GettingAccessToken;
        [self startAuthenticationProcess];
    }];
    return session;
}

#pragma mark - Helper

- (BOOL)isValidRequestTokenResponse:(NSString *)responseString {
    if (responseString == nil) return NO;
    NSArray *queryItem = [responseString componentsSeparatedByString:@"&"];
    for (NSString *item in queryItem) {
        if ([item isEqualToString:@"oauth_callback_confirmed=true"]) return YES;
    }
    return NO;
}

- (BOOL)isValidAccessTokenResponse:(NSString *)responseString {
    if (responseString == nil) return NO;
    NSArray *queryItem = [responseString componentsSeparatedByString:@"&"];
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) return NO;
        if ([item[0] isEqualToString:@"user_nsid"]) return YES;
    }
    return NO;
}

- (BOOL)isValidAuthorizationResponse:(NSString *)responseString {
    if (responseString == nil) return NO;
    NSArray *queryItem = [responseString componentsSeparatedByString:@"&"];
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) return NO;
        if ([item[0] isEqualToString:@"oauth_verifier"]) return YES;
    }
    return NO;
}

- (BOOL)isParseRequestTokenAndSecretSuccessfulFromQuery:(NSString *)queryString {
    BOOL isSuccessful = NO;
    NSArray *queryItem = [queryString componentsSeparatedByString:@"&"];
    NSString *token = @"";
    NSString *secret = @"";
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) continue;
        if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
        if ([item[0] isEqualToString:@"oauth_token_secret"]) secret = item[1];
    }
    if (![token isEqualToString:@""] &&
        ![secret isEqualToString:@""]) {
        isSuccessful = YES;
        oauthToken = token;
        oauthTokenSecret = secret;
    }
    return isSuccessful;
}

- (BOOL)isParseTokenAndVerifierSuccessfulFromQuery:(NSString *)queryString {
    BOOL isSuccessful = NO;
    NSArray *queryItem = [queryString componentsSeparatedByString:@"&"];
    NSString *token = @"";
    NSString *verifier = @"";
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) continue;
        if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
        if ([item[0] isEqualToString:@"oauth_verifier"]) verifier = item[1];
    }
    if (![token isEqualToString:@""] &
        ![verifier isEqualToString:@""]) {
        isSuccessful = YES;
        oauthVerifier = verifier;
    }
    return isSuccessful;
}

- (BOOL)isParseAccessTokenAndSecretSuccessfulFromQuery:(NSString *)queryString {
    BOOL isSuccessful = NO;
    NSArray *queryItem = [queryString componentsSeparatedByString:@"&"];
    NSString *token = @"";
    NSString *secret = @"";
    NSString *nsid = @"";
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) continue;
        if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
        if ([item[0] isEqualToString:@"oauth_token_secret"]) secret = item[1];
        if ([item[0] isEqualToString:@"user_nsid"]) nsid = item[1];
    }
    if (![token isEqualToString:@""] &&
        ![secret isEqualToString:@""]) {
        isSuccessful = YES;
        nsid = [nsid stringByRemovingPercentEncoding];
        userNSID = nsid;
        accessToken = token;
        secretToken = secret;
    }
    return isSuccessful;
}

- (void)resetVariables {
    oauthToken = @"";
    oauthTokenSecret = @"";
    oauthVerifier = @"";
    oauthAuthorizationURL = @"";
    userNSID = @"";
    accessToken = @"";
    secretToken = @"";
}

@end
