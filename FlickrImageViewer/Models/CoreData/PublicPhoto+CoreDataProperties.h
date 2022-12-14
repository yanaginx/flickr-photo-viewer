//
//  PublicPhoto+CoreDataProperties.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "PublicPhoto+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PublicPhoto (CoreDataProperties)

+ (NSFetchRequest<PublicPhoto *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nonatomic) float imageHeight;
@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nonatomic) float imageWidth;

@end

NS_ASSUME_NONNULL_END
