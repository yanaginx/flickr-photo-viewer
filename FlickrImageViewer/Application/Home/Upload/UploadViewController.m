//
//  UploadViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "UploadViewController.h"
#import "../../../Common/Constants/Constants.h"
#import "UploadPostViewController.h"

#import "Views/GalleryCollectionViewCell.h"
#import "DataSource/GalleryDataSource.h"

@interface UploadViewController () <UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GalleryDataSource *dataSource;

@end

@implementation UploadViewController

static int rowCount = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupTitle];
    [self setupNextButton];
    [self setupDismissButton];
    [self setupCollectionView];
}

#pragma mark - Operations

- (void)setupTitle {
    self.navigationItem.title = @"Photo library";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)setupNextButton {
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(navigateToPostView)];
    [self.navigationItem setRightBarButtonItem:nextButton];
}

- (void)setupDismissButton {
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(dismiss)];
    [self.navigationItem setLeftBarButtonItem:dismissButton];
}

- (void)setupCollectionView {
    self.collectionView.frame = self.view.bounds;
    CGFloat cellWidth = (self.collectionView.frame.size.width - (2 * kMargin * ((CGFloat)rowCount - 1))) / (CGFloat)rowCount;
    CGSize targetSize = CGSizeMake(cellWidth, cellWidth);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = targetSize;
    layout.minimumLineSpacing = kMargin;
    layout.minimumInteritemSpacing = kMargin;
    layout.sectionInset = UIEdgeInsetsMake(kMargin,
                                           kMargin,
                                           kMargin,
                                           kMargin);
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - Handlers

- (void)navigateToPostView {
    UploadPostViewController *uploadPostVC = [[UploadPostViewController alloc] init];
    [self.navigationController pushViewController:uploadPostVC
                                         animated:YES];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Accessors
- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
   
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:layout];

    [_collectionView registerClass:[GalleryCollectionViewCell class]
        forCellWithReuseIdentifier:GalleryCollectionViewCell.reuseIdentifier];
    
    return _collectionView;

}

- (GalleryDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    _dataSource = [[GalleryDataSource alloc] init];
    return _dataSource;
}

@end
