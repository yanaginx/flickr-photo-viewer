//
//  AlbumPhoto+CoreDataProperties.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "AlbumPhoto+CoreDataProperties.h"

@implementation AlbumPhoto (CoreDataProperties)

+ (NSFetchRequest<AlbumPhoto *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AlbumPhoto"];
}

@dynamic imageURL;
@dynamic albumID;
@dynamic album;

@end
