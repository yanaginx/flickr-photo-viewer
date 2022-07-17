//
//  PublicPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import "PublicPhotoManager.h"
#import "../../../../Models/Photo.h"

#import "../../../Login/Handlers/LoginHandler.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Utilities/Reachability/Reachability.h"
#import "../../../../Common/Constants/Constants.h"

@implementation PublicPhotoManager

#pragma mark - Make request

- (void)getPublicPhotoURLsWithPage:(NSInteger)pageNum
                 completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable,
                                          NSError * _Nullable))completion {
    // Fetch from core data when there is no internet
    if (![self _isConnected]) {
        // TODO: Fetch from core data first
        
        // If there is no offline data then return the no internet error
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:kNetworkError
                                         userInfo:nil];
        completion(nil, error);
        return;
    }
    
    NSURLRequest *request = [self _publicPhotoURLRequestWithPageNum:pageNum];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"[DEBUG] error: %@", error.localizedDescription);
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
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        if (localError) {
            completion(nil, localError);
            return;
        }
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"] ||
            [[parsedObject objectForKey:@"photos"] objectForKey:@"photo"] == nil) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSArray *photoObjects = [[parsedObject objectForKey:@"photos"] objectForKey:@"photo"];
        if (photoObjects.count == 0 && pageNum == 1) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNoDataError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSMutableArray *photos = [NSMutableArray array];
        for (NSDictionary *photoObject in photoObjects) {
            NSString *photoID = (NSString *)[photoObject objectForKey:@"id"];
            NSString *photoSecret = (NSString *)[photoObject objectForKey:@"secret"];
            NSString *photoServer = (NSString *)[photoObject objectForKey:@"server"];
            NSURL *photoURL = [ImageURLBuilder photoURLFromServerID:photoServer
                                                            photoID:photoID
                                                             secret:photoSecret
                                                         sizeSuffix:nil];
            
            NSNumber *heightFetched = (NSNumber *)[photoObject objectForKey:@"height_t"];
            NSNumber *widthFetched = (NSNumber *)[photoObject objectForKey:@"width_t"];
            CGFloat aspectRatio = heightFetched.floatValue / widthFetched.floatValue;
            CGFloat height_m = 0;
            CGFloat width_m = 0;
            if (heightFetched.longValue == 100) {
                height_m = 500;
                width_m = height_m / aspectRatio;
            } else if (widthFetched.longValue == 100) {
                width_m = 500;
                height_m = width_m * aspectRatio;
            }
            if (width_m == 0 || height_m == 0) {
                height_m = heightFetched.floatValue;
                width_m = widthFetched.floatValue;
            }
            CGSize imageSize = CGSizeMake(width_m, height_m);
            
            Photo *photo = [[Photo alloc] initWithImageURL:photoURL
                                                 imageSize:imageSize];
            [photos addObject:photo];
        }
        completion(photos, nil);
        
    }] resume];
}

#pragma mark - Private methods
- (BOOL)_isConnected {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if (reach.currentReachabilityStatus != NotReachable) {
        NSLog(@"[DEBUG] %s: Is Connected", __func__);
        return YES;
    }
    NSLog(@"[DEBUG] %s: Not connected", __func__);
    return NO;
}

#pragma mark - Network related
- (NSURLRequest *)_publicPhotoURLRequestWithPageNum:(NSInteger)pageNum {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kConsumerKey forKey:@"api_key"];
    [params setObject:kPublicPhotosMethod forKey:@"method"];
    [params setObject:AccountManager.userNSID forKey:@"user_id"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];
    [params setObject:kResultsPerPage forKey:@"per_page"];
    [params setObject:@"url_t" forKey:@"extras"];
    
    NSString *page = [NSString stringWithFormat:@"%ld", pageNum];
    [params setObject:page forKey:@"page"];
    
        
    NSURLRequest *request = [OAuth URLRequestForPath:@"/"
                                       GETParameters:params
                                              scheme:@"https"
                                                host:kAPIEndpoint
                                         consumerKey:kConsumerKey
                                      consumerSecret:nil
                                         accessToken:nil
                                         tokenSecret:nil];
    return request;
}

@end

