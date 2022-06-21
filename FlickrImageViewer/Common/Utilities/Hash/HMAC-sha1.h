//
//  HMAC-sha1.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMAC_sha1 : NSObject

- (NSData *)hmacForKeyAndData:(NSString *)key data:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
