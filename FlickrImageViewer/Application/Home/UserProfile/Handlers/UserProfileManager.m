//
//  UserProfileManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import "UserProfileManager.h"
#import "../../../Login/Handlers/LoginHandler.h"

#import "../../../../Models/Photo.h"
#import "../../../../Models/CoreData/UserInfo+CoreDataClass.h"
#import "../../../../Models/CoreData/UserInfo+CoreDataProperties.h"

#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Utilities/DataController/DataController.h"
#import "../../../../Common/Utilities/Reachability/Reachability.h"
#import "../../../../Common/Constants/Constants.h"

@interface UserProfileManager ()

@property (nonatomic, strong) DataController *dataController;

@end

@implementation UserProfileManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataController = [[DataController alloc] initWithModelName:kModelName];
        [self.dataController loadWithCompletionHandler:^{
            NSLog(@"[INFO] %s: Container loaded!", __func__);
        }];
    }
    return self;
}

#pragma mark - Make request
- (void)getUserProfileWithCompletionHandler:(void (^)(NSURL * _Nullable,
                                                      NSString * _Nullable,
                                                      NSString * _Nullable,
                                                      NSError * _Nullable))completion {
    // Fetching from core data when no internet
    if (![self _isConnected]) {
        UserInfo *userInfo = [self _fetchUserInfoFromLocal];
        if (userInfo) {
            NSURL *avatarURL = [NSURL URLWithString:userInfo.avatarURL];
            NSString *photoCounts = [NSString stringWithFormat:@"%d",
                                     userInfo.photosCount];
            completion(avatarURL, userInfo.name, photoCounts, nil);
            return;
        }
        // if no data then log the network error
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:kNetworkError
                                         userInfo:nil];
        completion(nil, nil, nil, error);
    }
    
    NSURLRequest *request = [self _userProfileURLRequest];
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
            completion(nil, nil, nil, error);
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNetworkError
                                             userInfo:nil];
            completion(nil, nil, nil, error);
            return;
        }
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        if (localError) {
            completion(nil, nil, nil, localError);
            return;
        }
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"]) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, nil, nil, error);
            return;
        }
        
        NSDictionary *personProfile = [parsedObject objectForKey:@"person"];
        
        NSNumber *iconFarmValue = (NSNumber *)[personProfile objectForKey:@"iconfarm"];
        NSInteger iconFarm = 0;
        if (iconFarmValue) iconFarm = iconFarmValue.integerValue;
        NSString *iconServer = (NSString *)[personProfile objectForKey:@"iconserver"];
        NSURL *avatarURL = [ImageURLBuilder buddyIconURLFromIconFarm:iconFarm
                                                          iconServer:iconServer
                                                                nsid:AccountManager.userNSID];
        
        NSString *name = (NSString *)[[personProfile objectForKey:@"realname"]
                                      objectForKey:@"_content"];
        
        NSString *photosCount = (NSString *)[[[personProfile objectForKey:@"photos"]
                                              objectForKey:@"count"]
                                              objectForKey:@"_content"];
        // Save to core data when finish fetching
        BOOL isSaveToCoreDataSuccessful = [self _saveUserInfoWithAvatarURL:avatarURL.absoluteString
                                                                      name:name
                                                            numberOfPhotos:photosCount.integerValue];
        if (isSaveToCoreDataSuccessful) {
            NSLog(@"[DEBUG] %s: save to core data ok!", __func__);
        }
        completion(avatarURL, name, photosCount, nil);
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

- (UserInfo *)_fetchUserInfoFromLocal {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
    NSError *error = nil;
    NSArray *results = [self.dataController.backgroundContext executeFetchRequest:request error:&error];
    if (!results && error) {
        NSLog(@"[ERROR] Error fetching UserInfo objects: %@\n%@",
              [error localizedDescription],
              [error userInfo]);
        return nil;
    }
    for (UserInfo *userInfo in results) {
        NSLog(@"[DEBUG] %s: fetched result with userinfo name: %@\nuserinfo avatar URL: %@\nuserinfo photosCount: %d",
              __func__,
              userInfo.name,
              userInfo.avatarURL,
              userInfo.photosCount);
    }
    if (results.count == 0) return nil;
    return results[0];
}

- (BOOL)_saveUserInfoWithAvatarURL:(NSString *)avatarURL
                              name:(NSString *)name
                    numberOfPhotos:(NSInteger)numberOfPhotos {
    UserInfo *userInfo = [NSEntityDescription
                          insertNewObjectForEntityForName:@"UserInfo"
                          inManagedObjectContext:self.dataController.backgroundContext];
    userInfo.avatarURL = avatarURL;
    userInfo.name = name;
    userInfo.photosCount = numberOfPhotos;
    // save the context
    NSError *error = nil;
    if ([self.dataController.backgroundContext save:&error] == NO) {
        NSLog(@"Error saving context: %@\n%@",
              error.localizedDescription,
              error.userInfo);
        return NO;
    }
    return YES;
}

#pragma mark - Network related
- (NSURLRequest *)_userProfileURLRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kConsumerKey forKey:@"api_key"];
    [params setObject:kUserProfileMethod forKey:@"method"];
    [params setObject:AccountManager.userNSID forKey:@"user_id"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];
    [params setObject:kResultsPerPage forKey:@"per_page"];
    
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
