//
//  PopularPhoto+CoreDataProperties.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "PopularPhoto+CoreDataProperties.h"

@implementation PopularPhoto (CoreDataProperties)

+ (NSFetchRequest<PopularPhoto *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PopularPhoto"];
}

@dynamic imageURL;
@dynamic imageHeight;
@dynamic imageWidth;

@end
