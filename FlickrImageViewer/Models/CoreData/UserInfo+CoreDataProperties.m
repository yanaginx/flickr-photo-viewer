//
//  UserInfo+CoreDataProperties.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 17/07/2022.
//
//

#import "UserInfo+CoreDataProperties.h"

@implementation UserInfo (CoreDataProperties)

+ (NSFetchRequest<UserInfo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
}

@dynamic avatarURL;
@dynamic name;
@dynamic photosCount;

@end
