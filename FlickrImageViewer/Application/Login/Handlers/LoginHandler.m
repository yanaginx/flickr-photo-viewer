//
//  LoginHandler.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

#import "LoginHandler.h"

#import "../../../Common/Utilities/TDOAuth/TDOAuth.h"
#import "../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../Common/Constants/Constants.h"


@interface LoginHandler ()

- (NSURLRequest *)requestTokenURLRequest;

@end

@implementation LoginHandler

static NSString *authorizationEndpoint = @"https://www.flickr.com/services/oauth/authorize";
static NSString *oauthConsumerKey = kConsumerKey;
static NSString *oauthConsumerSecret = kConsumerSecret;
static NSString *oauthCallbackURL = kCallbackURL;
static NSString *oauthHost = @"www.flickr.com/services/oauth";

static NSString *requestTokenPath = @"/request_token";
static NSString *accessTokenPath = @"/access_token";

+ (instancetype)sharedLoginHandler {
    static dispatch_once_t onceToken;
    static LoginHandler *shared;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initPrivate];
    });
    return shared;
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}

#pragma mark - Token URL & URLRequest

- (NSURLRequest *)requestTokenURLRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oauthCallbackURL forKey:@"oauth_callback"];
        
    NSURLRequest *request = [OAuth URLRequestForPath:requestTokenPath
                                       GETParameters:params
                                              scheme:@"https"
                                                host:oauthHost
                                         consumerKey:oauthConsumerKey
                                      consumerSecret:oauthConsumerSecret
                                         accessToken:nil
                                         tokenSecret:nil];
    return request;
}

- (NSURLRequest *)accessTokenURLRequest {
    NSString *requestAccessToken = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token"];
    NSString *requestTokenSecret = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token_secret"];
    NSString *requestVerifier = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_verifier"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oauthCallbackURL forKey:@"oauth_callback"];
    [params setObject:requestVerifier forKey:@"oauth_verifier"];
    

    NSURLRequest *request = [OAuth URLRequestForPath:accessTokenPath
                                       GETParameters:params
                                              scheme:@"https"
                                                host:oauthHost
                                         consumerKey:oauthConsumerKey
                                      consumerSecret:oauthConsumerSecret
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
                                                                    authorizationEndpoint,
                                                                    requestOAuthToken];
    
    return [NSURL URLWithString:authorizationURLString];
}

- (NSString *)callbackURLScheme {
    return @"flickrz";
}

#pragma mark - Authorization Session
- (ASWebAuthenticationSession *)authSessionWithCompletionHandler:(void (^)(NSString * _Nullable token,
                                                                           NSString * _Nullable verifier,
                                                                           NSError * _Nullable error))completion {
    ASWebAuthenticationSession *session = [[ASWebAuthenticationSession alloc] initWithURL:self.authorizationURL
                                                                        callbackURLScheme:self.callbackURLScheme
                                                                        completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        if (callbackURL == nil) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:LoginHandlerErrorNetworkError
                                             userInfo:nil];
            completion(nil, nil, error);
            return;
        }
        NSLog(@"[DEBUG] %s: url: %@", __func__, !callbackURL.baseURL ? @"No base URL" : callbackURL.baseURL.absoluteString);
        NSLog(@"[DEBUG] %s: url query: %@", __func__, !callbackURL.query ? @"No query string" : callbackURL.query);
        if (callbackURL.query == nil || !isValidAuthorizationResponse(callbackURL.query)) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:LoginHandlerErrorNotValidData
                                             userInfo:nil];
            completion(nil, nil, error);
            return;
        }
        [self parseTokenAndVerifierFromQuery:callbackURL.query];
        NSString *token = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token"];
        NSString *tokenVerifier = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_verifier"];
        completion(token, tokenVerifier, nil);
    }];
    return session;
}

#pragma mark - Make request
- (void)getRequestTokenWithCompletionHandler:(void (^)(NSString * _Nullable oauthToken,
                                                       NSString * _Nullable oauthTokenSecret,
                                                       NSError * _Nullable error))completion {
    
    NSURLRequest *request = [self requestTokenURLRequest];
    [[[NSURLSession sharedSession]
      dataTaskWithRequest:request
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:LoginHandlerErrorNetworkError
                                             userInfo:nil];
            completion(nil, nil, error);
        }
        NSString *responseDataString = [[NSString alloc] initWithData:data
                                                             encoding:NSASCIIStringEncoding];
        if (!isValidRequestTokenResponse(responseDataString)) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:LoginHandlerErrorNotValidData
                                             userInfo:nil];
            completion(nil, nil, error);
        }
        NSLog(@"[DEBUG] %s : request access token response: %@", __func__, responseDataString);
        [self parseRequestTokenAndSecretFromQuery:responseDataString];
        NSString *token = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token"];
        NSString *tokenSecret = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token_secret"];
        completion(token, tokenSecret, nil);
    }] resume];
}

- (void)getAccessTokenWithCompletionHandler:(void (^)(NSString * _Nullable oauthToken,
                                                      NSString * _Nullable oauthTokenSecret,
                                                      NSError * _Nullable))completion {
    NSURLRequest *request = [self accessTokenURLRequest];
    [[[NSURLSession sharedSession]
      dataTaskWithRequest:request
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:LoginHandlerErrorNetworkError
                                             userInfo:nil];
            completion(nil, nil, error);
        }
        NSString *responseDataString = [[NSString alloc] initWithData:data
                                                             encoding:NSASCIIStringEncoding];
        if (!isValidAccessTokenResponse(responseDataString)) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:LoginHandlerErrorNotValidData
                                             userInfo:nil];
            NSLog(@"[DEBUG] %s: invalid response data: %@", __func__, responseDataString);
            completion(nil, nil, error);
        }
        [self parseAccessTokenAndSecretFromQuery:responseDataString];
        NSString *token = [NSUserDefaults.standardUserDefaults stringForKey:@"user_oauth_token"];
        NSString *tokenSecret = [NSUserDefaults.standardUserDefaults stringForKey:@"user_oauth_token_secret"];
        completion(token, tokenSecret, nil);
    }] resume];
}

#pragma mark - Helper

BOOL isValidRequestTokenResponse(NSString *responseString) {
    NSArray *queryItem = [responseString componentsSeparatedByString:@"&"];
    for (NSString *item in queryItem) {
        if ([item isEqualToString:@"oauth_callback_confirmed=true"]) return YES;
    }
    return NO;
}

BOOL isValidAccessTokenResponse(NSString *responseString) {
    NSArray *queryItem = [responseString componentsSeparatedByString:@"&"];
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) return NO;
        if ([item[0] isEqualToString:@"user_nsid"]) return YES;
    }
    return NO;
}

BOOL isValidAuthorizationResponse(NSString *responseString) {
    NSArray *queryItem = [responseString componentsSeparatedByString:@"&"];
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) return NO;
        if ([item[0] isEqualToString:@"oauth_verifier"]) return YES;
    }
    return NO;
}

- (void)parseRequestTokenAndSecretFromQuery:(NSString *)queryString {
    NSArray *queryItem = [queryString componentsSeparatedByString:@"&"];
    NSString *token = @"";
    NSString *secret = @"";
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) continue;
        if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
        if ([item[0] isEqualToString:@"oauth_token_secret"]) secret = item[1];
    }
    if ([token isEqualToString:@""] || [secret isEqualToString:@""]) return;
    [NSUserDefaults.standardUserDefaults setObject:token forKey:@"request_oauth_token"];
    [NSUserDefaults.standardUserDefaults setObject:secret forKey:@"request_oauth_token_secret"];
}

- (void)parseTokenAndVerifierFromQuery:(NSString *)queryString {
    NSArray *queryItem = [queryString componentsSeparatedByString:@"&"];
    NSString *token = @"";
    NSString *verifier = @"";
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) continue;
        if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
        if ([item[0] isEqualToString:@"oauth_verifier"]) verifier = item[1];
    }
    if ([token isEqualToString:@""] || [verifier isEqualToString:@""]) return;
    [NSUserDefaults.standardUserDefaults setObject:token forKey:@"request_oauth_token"];
    [NSUserDefaults.standardUserDefaults setObject:verifier forKey:@"request_oauth_verifier"];
}

- (void)parseAccessTokenAndSecretFromQuery:(NSString *)queryString {
    NSArray *queryItem = [queryString componentsSeparatedByString:@"&"];
    NSString *token = @"";
    NSString *secret = @"";
    NSString *userNSID = @"";
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) continue;
        if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
        if ([item[0] isEqualToString:@"oauth_token_secret"]) secret = item[1];
        if ([item[0] isEqualToString:@"user_nsid"]) userNSID = item[1];
    }
    if ([token isEqualToString:@""] || [secret isEqualToString:@""]) return;
    userNSID = [userNSID stringByRemovingPercentEncoding];
    [NSUserDefaults.standardUserDefaults setObject:userNSID forKey:@"user_nsid"];
    [NSUserDefaults.standardUserDefaults setObject:token forKey:@"user_oauth_token"];
    [NSUserDefaults.standardUserDefaults setObject:secret forKey:@"user_oauth_token_secret"];
}

//- (void)_removeUserAccessTokenAndSecret {
- (void)removeUserAccessTokenAndSecret {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"request_oauth_verifier"];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"request_oauth_token_secret"];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"request_oauth_token"];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"user_oauth_token"];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"user_oauth_token_secret"];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"user_nsid"];
}



@end
