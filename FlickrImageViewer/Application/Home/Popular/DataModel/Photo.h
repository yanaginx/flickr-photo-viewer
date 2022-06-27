//
//  Photo.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Photo : NSObject

@property NSString *ID;
@property NSString *secret;
@property NSString *server;
@property NSString *sizeSuffix;

@end

NS_ASSUME_NONNULL_END
