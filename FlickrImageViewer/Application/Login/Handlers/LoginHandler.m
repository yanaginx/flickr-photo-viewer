//
//  LoginHandler.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

#import "LoginHandler.h"

#import "../../../Common/Utilities/TDOAuth/TDOAuth.h"
#import "../../../Common/Utilities/OAuth1.0/OAuth.h"

@implementation LoginHandler

static NSString *authorizationEndpoint = @"https://www.flickr.com/services/oauth/authorize";
static NSString *oauthConsumerKey = @"68fb93124728e9d210ca6dd75e1ba96d";
static NSString *oauthConsumerSecret = @"b55ec59d57a6e559";
static NSString *oauthCallbackURL = @"flickrz://";

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

#pragma mark - Token URL

- (NSURLRequest *)requestTokenURLRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oauthCallbackURL forKey:@"oauth_callback"];
        
    NSURLRequest *request = [OAuth URLRequestForPath:@"/request_token"
                                       GETParameters:params
                                              scheme:@"https"
                                                host:@"www.flickr.com/services/oauth"
                                         consumerKey:oauthConsumerKey
                                      consumerSecret:oauthConsumerSecret
                                         accessToken:nil
                                         tokenSecret:nil];
    return request;
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

#pragma mark - Make request
- (void)getRequestTokenWithCompletionHandler:(void (^)(NSString * _Nullable responseString,
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
        if (!isValidResponse(responseDataString)) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:LoginHandlerErrorNotValidData
                                             userInfo:nil];
            completion(nil, nil, error);
        }
//        NSArray *queryItem = [responseDataString componentsSeparatedByString:@"&"];
//        NSString *token = @"";
//        NSString *secret = @"";
//        for (NSString *pair in queryItem) {
//            NSArray *item = [pair componentsSeparatedByString:@"="];
//            if (item.count != 2) continue;
//            if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
//            if ([item[0] isEqualToString:@"oauth_token_secret"]) secret = item[1];
//        }
//        [NSUserDefaults.standardUserDefaults setObject:token forKey:@"request_oauth_token"];
//        [NSUserDefaults.standardUserDefaults setObject:secret forKey:@"request_oauth_token_secret"];
        [self parseTokenAndSecretFromQuery:responseDataString];
        NSString *token = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token"];
        NSString *tokenSecret = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_token_secret"];
        completion(token, tokenSecret, nil);
    }] resume];
}

#pragma mark - Helper

BOOL isValidResponse(NSString * responseString) {
    NSArray *queryItem = [responseString componentsSeparatedByString:@"&"];
    for (NSString *item in queryItem) {
        if ([item isEqualToString:@"oauth_callback_confirmed=true"]) return YES;
    }
    return NO;
}

- (void)parseTokenAndSecretFromQuery:(NSString *)queryString {
    NSArray *queryItem = [queryString componentsSeparatedByString:@"&"];
    NSString *token = @"";
    NSString *secret = @"";
    for (NSString *pair in queryItem) {
        NSArray *item = [pair componentsSeparatedByString:@"="];
        if (item.count != 2) continue;
        if ([item[0] isEqualToString:@"oauth_token"]) token = item[1];
        if ([item[0] isEqualToString:@"oauth_token_secret"]) secret = item[1];
    }
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
    [NSUserDefaults.standardUserDefaults setObject:token forKey:@"request_oauth_token"];
    [NSUserDefaults.standardUserDefaults setObject:verifier forKey:@"request_oauth_verifier"];
}


@end
