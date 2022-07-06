//
//  UploadPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "UploadPhotoManager.h"

#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Utilities/XMLReader/XMLReader.h"
#import "../../../../Common/Constants/Constants.h"

@implementation UploadPhotoManager

- (void)uploadUserImage:(UIImage *)image
                  title:(NSString *)imageName
            description:(NSString *)imageDescription
      completionHandler:(void (^)(NSString *  _Nullable,
                                  NSError * _Nullable))completion {
    NSURLRequest *request = [self uploadPhotoURLRequestWithImage:image
                                                           title:imageName
                                                     description:imageDescription];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error) {
        if (error) {
            if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] ||
                [error.localizedDescription isEqualToString:@"The request timed out."]) {
                error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                            code:kNetworkError
                                        userInfo:nil];
            }
            completion(nil, error);
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNetworkError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSString *responseDataString = [[NSString alloc] initWithData:data
                                                             encoding:NSASCIIStringEncoding];
        
        NSLog(@"[DEBUG] %s : response string result: %@", __func__, responseDataString);
        BOOL isUploadSuccessful = [self isUploadSuccessfulFromResponseData:data];
        
        if (!isUploadSuccessful) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        completion(imageName, nil);
        
    }] resume];
}

#pragma mark - Network related
- (NSURLRequest *)uploadPhotoURLRequestWithImage:(UIImage *)image
                                           title:(NSString *)title
                                     description:(NSString *)description {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kConsumerKey forKey:@"api_key"];
    [params setObject:AccountManager.userNSID forKey:@"user_id"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];
    [params setObject:title forKey:@"title"];
    [params setObject:description forKey:@"description"];
    
    NSMutableURLRequest *requestWithSignature =
    [[OAuth URLRequestUsingQueryAndMultipartFormDataForPath:@"/"
                                             POSTParameters:params
                                                       host:kUploadEndpoint
                                                consumerKey:kConsumerKey
                                             consumerSecret:kConsumerSecret
                                                accessToken:AccountManager.userAccessToken
                                                tokenSecret:AccountManager.userSecretToken]
     mutableCopy];
    
    // Adding images body
    NSMutableData *postBody = [NSMutableData data];
    [OAuth appendToPOSTBody:postBody
                       name:@"title"
                      value:title];
    [OAuth appendToPOSTBody:postBody
                       name:@"description"
                      value:description];
    [OAuth appendToPOSTBody:postBody
                       name:[NSString stringWithFormat:@"photo"]
                   fileName:[NSString stringWithFormat:@"%@.jpg", title]
                       data:imageData];
    [OAuth appendEndOfMultipartFormDataToPOSTBody:postBody];
    
    // add set body to the request
    requestWithSignature.HTTPBody = postBody;
    NSLog(@"%s : Request body %@",
          __func__,
          [[NSString alloc] initWithData:requestWithSignature.HTTPBody
                                encoding:NSASCIIStringEncoding]);
    
    return requestWithSignature;
}

#pragma mark - Operations
- (BOOL)isUploadSuccessfulFromResponseData:(NSData *)responseData {
    BOOL isSuccessful = NO;
    NSError *localError = nil;
    NSDictionary *parsedResponse = [XMLReader dictionaryForXMLData:responseData error:&localError];
    if (localError) {
        isSuccessful = NO;
    }
    NSString *result = [[parsedResponse objectForKey:@"rsp"] objectForKey:@"stat"];
    if ([result isEqualToString:@"ok"]) {
        isSuccessful = YES;
    }
    return isSuccessful;
}

@end
