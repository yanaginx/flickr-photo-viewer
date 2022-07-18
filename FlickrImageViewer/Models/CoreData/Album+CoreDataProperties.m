//
//  Album+CoreDataProperties.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "Album+CoreDataProperties.h"

@implementation Album (CoreDataProperties)

+ (NSFetchRequest<Album *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Album"];
}

@dynamic albumID;
@dynamic albumImageURL;
@dynamic albumName;
@dynamic creatationDate;
@dynamic numbersOfPhoto;
@dynamic albumPhoto;

@end
