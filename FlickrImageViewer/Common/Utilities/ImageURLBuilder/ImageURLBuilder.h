//
//  ImageURLBuilder.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 23/06/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageURLBuilder : NSObject

+ (NSURL *)photoURLFromServerID:(NSString *)serverID
                        photoID:(NSString *)photoID
                         secret:(NSString *)secret
                     sizeSuffix:(NSString * _Nullable)sizeSuffix;

+ (NSURL *)buddyIconURLFromIconFarm:(NSInteger)iconFarm
                         iconServer:(NSString *)iconServer
                               nsid:(NSString *)nsid;

@end

NS_ASSUME_NONNULL_END
