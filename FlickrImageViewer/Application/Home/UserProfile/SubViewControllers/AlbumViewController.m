//
//  AlbumViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import "AlbumViewController.h"

#import "../../../../Common/Layouts/FixedLayout/FixedFlowLayout.h"
#import "../../../../Common/Constants/Constants.h"

#import "../Views/AlbumInfoCollectionViewCell.h"
#import "DataSource/AlbumInfoDataSource.h"

@interface AlbumViewController () <UICollectionViewDelegate,
                                   UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FixedFlowLayout *fixedFlowLayout;
@property (nonatomic, strong) AlbumInfoDataSource *dataSource;

@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self setupCollectionView];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height);
    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width - _fixedFlowLayout.minimumLineSpacing * 2, self.collectionView.bounds.size.height / 3 - _fixedFlowLayout.minimumLineSpacing * 2);
}


#pragma mark - Operations
- (void)setupCollectionView {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
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
    
    [_collectionView registerClass:[AlbumInfoCollectionViewCell class]
        forCellWithReuseIdentifier:AlbumInfoCollectionViewCell.reuseIdentifier];
    
    return _collectionView;
}

- (AlbumInfoDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    
    _dataSource = [[AlbumInfoDataSource alloc] init];
    return _dataSource;
}

@end
