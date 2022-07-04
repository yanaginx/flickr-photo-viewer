//
//  AlbumDetailViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumDetailViewController.h"

#import "../../../../Common/Layouts/FixedLayout/FixedFlowLayout.h"
#import "../../../../Common/Constants/Constants.h"

#import "../Views/AlbumDetailCollectionViewCell.h"
#import "DataSource/AlbumDetailDataSource.h"

@interface AlbumDetailViewController () <UICollectionViewDelegate,
                                         UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FixedFlowLayout *fixedFlowLayout;
@property (nonatomic, strong) AlbumDetailDataSource *dataSource;

@end

@implementation AlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self setupCollectionView];
    [self setupTitleView];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height);
    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width / 2 - _fixedFlowLayout.minimumLineSpacing,
                                               self.collectionView.bounds.size.width / 2 - _fixedFlowLayout.minimumLineSpacing);
}


#pragma mark - Operations
- (void)setupCollectionView {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
}

- (void)setupTitleView {
    // template for image
    UIImage *albumCoverImage = [UIImage imageNamed:@"ic_no_data"];
    UIImageView *albumCoverImageView = [[UIImageView alloc] initWithImage:albumCoverImage];
    self.navigationItem.titleView = albumCoverImageView;
    self.navigationItem.title = @"Album Name";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

#pragma mark - Custom Accessors

- (FixedFlowLayout *)fixedFlowLayout {
    if (_fixedFlowLayout) return _fixedFlowLayout;
    
    _fixedFlowLayout = [[FixedFlowLayout alloc] init];
    _fixedFlowLayout.sectionInset = UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);

    return _fixedFlowLayout;
}

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:self.fixedFlowLayout];
    
    [_collectionView registerClass:[AlbumDetailCollectionViewCell class]
        forCellWithReuseIdentifier:AlbumDetailCollectionViewCell.reuseIdentifier];
    
    return _collectionView;
}

- (AlbumDetailDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    
    _dataSource = [[AlbumDetailDataSource alloc] init];
    return _dataSource;
}

@end

