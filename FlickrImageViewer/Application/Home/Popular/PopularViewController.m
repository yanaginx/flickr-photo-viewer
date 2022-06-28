//
//  PopularViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "PopularViewController.h"

#import "Handlers/PopularPhotoManager.h"

#import "../../../Common/Layouts/DynamicLayout/DynamicCollectionViewLayout.h"
#import "Views/PopularPhotoCollectionViewCell.h"


@interface PopularViewController () <DynamicCollectionViewLayoutDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<NSURL *> *photoURLs;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicLayout;
// cache for getting the image size
@property (nonatomic, strong) NSCache *photoImagesCache;

@end

@implementation PopularViewController

static NSInteger currentPage = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.cyanColor;
    [self getPhotoURLsForPage:currentPage];
}


#pragma mark - Private methods

- (void)getPhotoURLsForPage:(NSInteger)pageNum {
     [PopularPhotoManager.sharedPopularPhotoManager getPopularPhotoURLsWithPage:pageNum
                                                             completionHandler:^(NSMutableArray<NSURL *> * _Nullable photos,
                                                                                 NSError * _Nullable error) {
        if (error) {
            switch (error.code) {
                case PopularPhotoManagerErrorNetworkError:
                    // Network error view
                    break;
                default:
                    // Error occur view
                    break;
            }
        }
        self.photoURLs = photos;
    }];
}

#pragma mark - DynamicCollectionViewLayoutDataSource
- (CGSize)dynamicCollectionViewLayout:(DynamicCollectionViewLayout *)layout
         originalImageSizeAtIndexPath:(NSIndexPath *)indexPath {
    // Return the image size to the FixedHViewLayout
    return CGSizeMake(0.1, 0.1);
}

#pragma mark - Custom Accessors
- (DynamicCollectionViewLayout *)dynamicLayout {
    if (_dynamicLayout) return _dynamicLayout;

    _dynamicLayout = [[DynamicCollectionViewLayout alloc] init];
    _dynamicLayout.dataSource = self;
    return _dynamicLayout;
}

@end
