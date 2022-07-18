//
//  PublicPhoto+CoreDataProperties.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "PublicPhoto+CoreDataProperties.h"

@implementation PublicPhoto (CoreDataProperties)

+ (NSFetchRequest<PublicPhoto *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PublicPhoto"];
}

@dynamic imageHeight;
@dynamic imageURL;
@dynamic imageWidth;

@end
