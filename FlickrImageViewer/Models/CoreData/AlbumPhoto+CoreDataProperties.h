//
//  AlbumPhoto+CoreDataProperties.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "AlbumPhoto+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AlbumPhoto (CoreDataProperties)

+ (NSFetchRequest<AlbumPhoto *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nullable, nonatomic, copy) NSString *albumID;
@property (nullable, nonatomic, retain) Album *album;

@end

NS_ASSUME_NONNULL_END
