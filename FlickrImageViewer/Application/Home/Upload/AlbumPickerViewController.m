//
//  AlbumPickerViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 08/07/2022.
//

#import "AlbumPickerViewController.h"
#import "../../../Common/Layouts/FixedLayout/FixedFlowLayout.h"
#import "../../../Common/Constants/Constants.h"

#import "../../../Models/AlbumInfo.h"
#import "../../Home/UserProfile/Handlers/AlbumInfoManager.h"
#import "../../Home/UserProfile/Views/AlbumInfoCollectionViewCell.h"
#import "../../Home/UserProfile/SubViewControllers/DataSource/AlbumInfoDataSource.h"

#import "../../Error/NetworkErrorViewController.h"
#import "../../Error/ServerErrorViewController.h"
#import "../../Error/NoDataErrorViewController.h"

@interface AlbumPickerViewController () <UICollectionViewDelegate,
                                         UICollectionViewDelegateFlowLayout,
                                         NetworkErrorViewDelegate,
                                         ServerErrorViewDelegate,
                                         NoDataErrorViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FixedFlowLayout *fixedFlowLayout;
@property (nonatomic, strong) AlbumInfoDataSource *dataSource;
@property (nonatomic, strong) AlbumInfoManager *albumInfoManager;
@property (nonatomic, strong) AlbumInfo *selectedAlbumInfo;

@end

@implementation AlbumPickerViewController

static NSInteger currentPage = 1;
static BOOL isLastPage = NO;
static NSInteger numOfPhotosBeforeNewFetch = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    if (currentPage != 1) currentPage = 1;
    [self getAlbumInfosForPage:currentPage];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height);
    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width -
                                               _fixedFlowLayout.minimumLineSpacing * 2,
                                               kMaxRowHeight - _fixedFlowLayout.minimumLineSpacing * 2);
}


#pragma mark - Operations
- (void)setupViews {
    [self setupCollectionView];
    [self setupSaveButton];
}


- (void)setupCollectionView {
    self.collectionView.backgroundColor = UIColor.lightGrayColor;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = NO;
    [self.view addSubview:self.collectionView];
}

- (void)setupSaveButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveAlbumIDAndDismiss)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    [self toggleSaveButton];
}

- (void)saveAlbumIDAndDismiss {
    [self.delegate onFinishSelectAlbumInfo:self.selectedAlbumInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toggleSaveButton {
    if (self.selectedAlbumInfo) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)getAlbumInfosForPage:(NSInteger)pageNum {
   [self.albumInfoManager getUserAlbumInfosWithPage:pageNum
                                  completionHandler:^(NSMutableArray<AlbumInfo *> * _Nullable albumInfos,
                                                                                NSError * _Nullable error) {
        
        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            switch (error.code) {
                case kNetworkError:
                    // Network error view
                    NSLog(@"[DEBUG] %s : No internet connection", __func__);
                    [self viewNetworkError];
                    break;
                case kNoDataError:
                    // No data error view
                    NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                    [self viewNoDataError];
                    break;
                default:
                    // Error occur view
                    NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                    [self viewServerError];
                    break;
            }
            return;
        }
       if (albumInfos.count == 0) {
           isLastPage = YES;
       }
       [self.dataSource.albumInfos addObjectsFromArray:albumInfos];
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.collectionView reloadData];
       });
    }];
}

- (void)viewNetworkError {
    // Check if there is any image appear:
    if (self.dataSource.albumInfos.count > 0) {
        // Display toast only
        [self displayNetworkErrorToast];
    } else {
        [self displayNetworkErrorView];
    }
}

- (void)displayNetworkErrorView {
    dispatch_async(dispatch_get_main_queue(), ^{
        NetworkErrorViewController *networkErrorVC = [[NetworkErrorViewController alloc] init];
        networkErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        networkErrorVC.view.frame = self.view.bounds;
        networkErrorVC.delegate = self;
        [self.navigationController pushViewController:networkErrorVC animated:NO];
    });
}

- (void)displayNetworkErrorToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = @"Network connection unavailable";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        int duration = 1; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)viewNoDataError {
    dispatch_async(dispatch_get_main_queue(), ^{
        NoDataErrorViewController *noDataErrorVC = [[NoDataErrorViewController alloc] init];
        noDataErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        noDataErrorVC.view.frame = self.navigationController.view.bounds;
        noDataErrorVC.delegate = self;
        [self.navigationController pushViewController:noDataErrorVC animated:NO];
    });
}

- (void)viewServerError {
    dispatch_async(dispatch_get_main_queue(), ^{
        ServerErrorViewController *serverErrorVC = [[ServerErrorViewController alloc] init];
        serverErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        serverErrorVC.view.frame = self.view.bounds;
        serverErrorVC.delegate = self;
        [self.navigationController pushViewController:serverErrorVC animated:NO];
    });
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataSource.albumInfos.count - numOfPhotosBeforeNewFetch && !isLastPage) {
        currentPage += 1;
        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self getAlbumInfosForPage:currentPage];
    }
}

#pragma mark - NetworkErrorViewDelegate
- (void)onRetryForNetworkErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self getAlbumInfosForPage:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
     currentPage = 1;
    [self getAlbumInfosForPage:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self getAlbumInfosForPage:currentPage];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumInfo *albumInfo = self.dataSource.albumInfos[indexPath.row];
    NSLog(@"[DEBUG] %s : albumID: %@, albumName: %@", __func__, albumInfo.albumID, albumInfo.albumName);
    self.selectedAlbumInfo = albumInfo;
    [self toggleSaveButton];
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

- (AlbumInfoManager *)albumInfoManager {
    if (_albumInfoManager) return _albumInfoManager;
    
    _albumInfoManager = [[AlbumInfoManager alloc] init];
    return _albumInfoManager;
}
@end
