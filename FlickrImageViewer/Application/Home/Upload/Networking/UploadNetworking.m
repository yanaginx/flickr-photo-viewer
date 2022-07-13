//
//  UploadNetworking.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 11/07/2022.
//

#import "UploadNetworking.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Utilities/XMLReader/XMLReader.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Constants/Constants.h"

@implementation UploadNetworking

- (void)uploadUserImage:(UIImage *)image
                  title:(NSString *)imageName
            description:(NSString *)imageDescription
      completionHandler:(void (^)(NSString *  _Nullable,
                                  NSError * _Nullable))completion {
    NSURLRequest *request = [self _uploadPhotoURLRequestWithImage:image
                                                            title:imageName
                                                      description:imageDescription];
    NSData *bodyData = request.HTTPBody;
    [[[NSURLSession sharedSession] uploadTaskWithRequest:request
                                                fromData:bodyData
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
        NSString *successfulPhotoID = [self _uploadedPhotoIDWithResponseData:data];
        
        if (successfulPhotoID == nil) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        completion(successfulPhotoID, nil);
        
    }] resume];
}

- (void)addPhotoID:(NSString *)photoID
         toAlbumID:(NSString *)albumID
 completionHandler:(void (^)(NSString *  _Nullable status,
                             NSError * _Nullable error))completion {
    NSURLRequest *request = [self _addPhotoToAlbumURLRequestWithPhotoID:photoID
                                                                albumID:albumID];
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
        // TODO: check the return response:
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&localError];
        if (localError) {
            completion(nil, localError);
            return;
        }
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"]) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        completion(@"OK", nil);
    }] resume];

}

#pragma mark - URLRequest
- (NSURLRequest *)_uploadPhotoURLRequestWithImage:(UIImage *)image
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

- (NSURLRequest *)_addPhotoToAlbumURLRequestWithPhotoID:(NSString *)photoID
                                                albumID:(NSString *)albumID {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:photoID forKey:@"photo_id"];
    [params setObject:albumID forKey:@"photoset_id"];
    [params setObject:kAddPhotoToPhotosetMethod forKey:@"method"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];

    NSURLRequest *request = [OAuth URLRequestForPath:@"/"
                                       GETParameters:params
                                              scheme:@"https"
                                                host:kAPIEndpoint
                                         consumerKey:kConsumerKey
                                      consumerSecret:kConsumerSecret
                                         accessToken:AccountManager.userAccessToken
                                         tokenSecret:AccountManager.userSecretToken];
    return request;
}

#pragma mark - Helpers
- (NSString *)_uploadedPhotoIDWithResponseData:(NSData *)responseData {
    NSError *localError = nil;
    NSDictionary *parsedResponse = [XMLReader dictionaryForXMLData:responseData error:&localError];
    if (localError) {
        return nil;
    }
    NSString *result = [[parsedResponse objectForKey:@"rsp"] objectForKey:@"stat"];
    NSString *uploadedPhotoID = [[[parsedResponse objectForKey:@"rsp"]
                                  objectForKey:@"photoid"]
                                 objectForKey:@"text"];
    if (![result isEqualToString:@"ok"] ||
        uploadedPhotoID == nil) {
        return nil;
    }
    return uploadedPhotoID;
}

@end
