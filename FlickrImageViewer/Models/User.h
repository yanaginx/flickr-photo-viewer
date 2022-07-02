//
//  User.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject <NSCoding, NSSecureCoding>

@property NSString *NSID;
@property NSString *accessToken;
@property NSString *secretToken;

- (instancetype)initWithNSID:(NSString *)nsid
                 accessToken:(NSString *)accessToken
                 secretToken:(NSString *)secretToken;

@end

NS_ASSUME_NONNULL_END
