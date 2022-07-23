//
//  AlbumDetailPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumDetailPhotoManager.h"
#import "../../../../Models/Photo.h"
#import "../../../../Models/CoreData/AlbumPhoto+CoreDataClass.h"
#import "../../../../Models/CoreData/AlbumPhoto+CoreDataProperties.h"

#import "../../../Login/Handlers/LoginHandler.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Utilities/Reachability/Reachability.h"
#import "../../../../Common/Utilities/DataController/DataController.h"
#import "../../../../Common/Constants/Constants.h"

@interface AlbumDetailPhotoManager () {
    BOOL isOfflineFetched;
}

@property (nonatomic, strong) DataController *dataController;

@end

@implementation AlbumDetailPhotoManager

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

#pragma mark - Public methods
- (BOOL)isConnected {
    return [self _isConnected];
}

#pragma mark - Make request

- (void)getAlbumDetailPhotosForAlbumID:(NSString *)albumID
                                  page:(NSInteger)pageNum
                     completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable,
                                                 NSError * _Nullable,
                                                 NSNumber *))completion {
    if (![self _isConnected]) {
        // if fetched offline data then just return an empty array
        if (isOfflineFetched) {
            completion([NSMutableArray array], nil, nil);
            return;
        }
        // TODO: Fetch from core data first
        NSArray *albumPhotos = [self _fetchAlbumPhotosFromLocalWithAlbumID:albumID];
        // if there is data then transform it into the model then return
        if (albumPhotos && albumPhotos.count != 0) {
            NSMutableArray *photos = [self _extractPhotosFromAlbumPhotos:albumPhotos];
             // Printing all the photo fetched!
            NSLog(@"[DEBUG] %s: number of photos fetched offline: %lu",
                  __func__,
                  (unsigned long)photos.count);
            for (Photo *photo in photos) {
                NSLog(@"[DEBUG] %s: photo fetched offline: %@",
                      __func__,
                      photo.imageURL.absoluteString);
            }
            // END - printing all the photo fetched!
            isOfflineFetched = YES;
            completion(photos, nil, nil);
            return;
        }
        // If there is no offline data then return the no internet error
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:kNetworkError
                                         userInfo:nil];
        completion(nil, error, nil);
        return;
    }

    // else make the request as usual
    isOfflineFetched = NO;
    NSURLRequest *request = [self _albumDetailPhotosURLRequestWithAlbumID:albumID
                                                                  pageNum:pageNum];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error) {
        if (error) {
            NSLog(@"[DEBUG] error: %@", error.localizedDescription);
            if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] ||
                [error.localizedDescription isEqualToString:@"The request timed out."]) {
                error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                            code:kNetworkError
                                        userInfo:nil];
            }
            completion(nil, error, nil);
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNetworkError
                                             userInfo:nil];
            completion(nil, error, nil);
            return;
        }
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        if (localError) {
            completion(nil, localError, nil);
            return;
        }
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"] ||
            [[parsedObject objectForKey:@"photoset"] objectForKey:@"photo"] == nil) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error, nil);
            return;
        }
        
        NSNumber *totalPhotosNumber = [[parsedObject objectForKey:@"photoset"] objectForKey:@"total"];
        
        NSArray *photoObjects = [[parsedObject objectForKey:@"photoset"] objectForKey:@"photo"];
        if (photoObjects.count == 0 && pageNum == 1) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNoDataError
                                             userInfo:nil];
            completion(nil, error, nil);
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
            CGSize imageSize = CGSizeMake(width_m, height_m);
            
            Photo *photo = [[Photo alloc] initWithImageURL:photoURL
                                                 imageSize:imageSize];
            [photos addObject:photo];
            // Save the photo info into the core data
            BOOL isSaveToCoreDataSuccessful = [self _saveAlbumPhotosWithPhoto:photo
                                                                      albumID:albumID];
            if (!isSaveToCoreDataSuccessful) {
                NSLog(@"[DEBUG] %s: Something went wrong!", __func__);
            }
        }
        completion(photos, nil, totalPhotosNumber);
        
    }] resume];
}

- (void)clearLocalAlbumPhotosForAlbumID:(NSString *)albumID {
    [self _clearLocalAlbumPhotosForAlbumID:albumID];
}

#pragma mark - Private methods
- (BOOL)_isConnected {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if (reach.currentReachabilityStatus != NotReachable) {
//        NSLog(@"[DEBUG] %s: Is Connected", __func__);
        return YES;
    }
//    NSLog(@"[DEBUG] %s: Not connected", __func__);
    return NO;
}

- (NSArray *)_fetchAlbumPhotosFromLocalWithAlbumID:(NSString *)albumID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AlbumPhoto"];
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"albumID == %@", albumID];
    request.predicate = requestPredicate;
    
    NSError *error = nil;
    NSArray *results = [self.dataController.backgroundContext executeFetchRequest:request
                                                                            error:&error];
    if (!results && error) {
        NSLog(@"[ERROR] Error fetching public photos objects: %@\n%@",
              error.localizedDescription,
              error.userInfo);
        return nil;
    }
    return results;
}

- (BOOL)_saveAlbumPhotosWithPhoto:(Photo *)photo
                          albumID:(NSString *)albumID {
    AlbumPhoto *albumPhoto = [NSEntityDescription
                              insertNewObjectForEntityForName:@"AlbumPhoto"
                              inManagedObjectContext:self.dataController.backgroundContext];
    albumPhoto.imageURL = photo.imageURL.absoluteString;
    albumPhoto.albumID = albumID;
    // save the context
    NSError *error = nil;
    @try {
        if ([self.dataController.backgroundContext save:&error] == NO) {
            NSLog(@"Error saving context: %@\n%@",
                  error.localizedDescription,
                  error.userInfo);
            return NO;
        }
    } @catch (NSException *exception) {
        NSLog(@"[DEBUG] Error while saving context");
        return NO;
    }
//    if ([self.dataController.backgroundContext save:&error] == NO) {
//        NSLog(@"Error saving context: %@\n%@",
//              error.localizedDescription,
//              error.userInfo);
//        return NO;
//    }
    return YES;
}

- (NSMutableArray *)_extractPhotosFromAlbumPhotos:(NSArray *)albumPhotos {
    NSMutableArray *photos = [NSMutableArray array];
    // Convert core data data into model
    for (AlbumPhoto *albumPhoto in albumPhotos) {
        NSURL *photoURL = [NSURL URLWithString:albumPhoto.imageURL];
        Photo *photo = [[Photo alloc] initWithImageURL:photoURL
                                             imageSize:CGSizeZero];
        [photos addObject:photo];
    }
    return photos;
}

// Delete all records so far when refreshing
- (void)_clearLocalAlbumPhotosForAlbumID:(NSString *)albumID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AlbumPhoto"];
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"albumID == %@", albumID];
    request.predicate = requestPredicate;
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    NSError *deleteError = nil;
    [self.dataController.backgroundContext executeRequest:delete
                                                    error:&deleteError];
    if (deleteError) {
        // Something went wrong
        NSLog(@"[DEBUG] %s: delete not good: %@",
              __func__,
              deleteError.localizedDescription);
    }
    @try {
        if ([self.dataController.backgroundContext save:&deleteError] == NO) {
            NSLog(@"Error saving context: %@\n%@",
                  deleteError.localizedDescription,
                  deleteError.userInfo);
        }
    } @catch (NSException *exception) {
        NSLog(@"[DEBUG] Error while saving context");
    }
}



#pragma mark - Network related
- (NSURLRequest *)_albumDetailPhotosURLRequestWithAlbumID:(NSString *)albumID
                                                  pageNum:(NSInteger)pageNum {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kConsumerKey forKey:@"api_key"];
    [params setObject:kGetAlbumDetailPhotosMethod forKey:@"method"];
    [params setObject:AccountManager.userNSID forKey:@"user_id"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];
    [params setObject:kResultsPerPage forKey:@"per_page"];
    [params setObject:albumID forKey:@"photoset_id"];
    [params setObject:@"url_t" forKey:@"extras"];
    
    [params setObject:@"1" forKey:@"privacy_filter"];
    
    NSString *page = [NSString stringWithFormat:@"%ld", pageNum];
    [params setObject:page forKey:@"page"];
    
        
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


@end
