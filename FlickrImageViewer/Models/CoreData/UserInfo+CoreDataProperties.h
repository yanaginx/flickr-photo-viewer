//
//  UserInfo+CoreDataProperties.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "UserInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserInfo (CoreDataProperties)

+ (NSFetchRequest<UserInfo *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *avatarURL;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int16_t photosCount;

@end

NS_ASSUME_NONNULL_END
