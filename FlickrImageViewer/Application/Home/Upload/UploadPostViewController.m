//
//  UploadPostViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import "UploadPostViewController.h"
#import "Handlers/UploadPhotoManager.h"
#import "../../../Common/Constants/Constants.h"
#import "../../../Models/AlbumInfo.h"

#import "Views/GalleryCollectionViewCell.h"
#import "Views/RemainingPhotosNumberCollectionViewCell.h"
#import "Views/TitleTextField.h"
#import "Views/DescriptionTextField.h"
#import "Handlers/GalleryManager.h"

#import "AlbumPickerViewController.h"

#define kRowCount 4
#define kLastIndex kRowCount - 1
#define kNumberOfPhotosToDisplay 3
#define kNumberOfCellsToDisplay kNumberOfPhotosToDisplay + 1
#define kBorderWidth 2

@interface UploadPostViewController () <UICollectionViewDataSource,
                                        UICollectionViewDelegate,
                                        AlbumPickerDelegate> {
    NSInteger remainingPhotos;
}

@property (nonatomic, strong) UploadPhotoManager *uploadPhotoManager;
@property (nonatomic, strong) GalleryManager *galleryManager;

@property (nonatomic, copy) NSArray <PHAsset *>* assets;
@property (nonatomic, copy) AlbumInfo *selectedAlbumInfo;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) TitleTextField *titleTextField;
@property (nonatomic, copy) DescriptionTextField *descriptionTextField;
@property (nonatomic, strong) UIButton *albumSelectorButton;

@end

@implementation UploadPostViewController

- (instancetype)initWithUploadPhotoManager:(UploadPhotoManager *)uploadManager
                            galleryManager:(GalleryManager *)galleryManager {
    self = [self init];
    if (self) {
        self.galleryManager = galleryManager;
        self.uploadPhotoManager = uploadManager;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        remainingPhotos = 0;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[DEBUG] %s: did run!", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupViews];
    for (NSString *localIdentifier in [self.selectedAssets allKeys]) {
        NSLog(@"[DEBUG] %s: the asset selected: %@",
              __func__,
              [self.selectedAssets objectForKey:localIdentifier]);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Operations
- (void)_setupViews {
    self.view.backgroundColor = UIColor.whiteColor;
    [self _setupTitle];
    [self _setupPostButton];
    [self _setupCollectionView];
    [self _setupTitleTextField];
    [self _setupDescriptionTextField];
    [self _setupAlbumSelectorButton];
}


- (void)_setupTitle {
    self.navigationItem.title = NSLocalizedString(@"Upload Post title", nil);
}

- (void)_setupPostButton {
     UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post button label", nil)
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(_onPostButtonClicked)];
    [self.navigationItem setRightBarButtonItem:postButton];
}

- (void)_setupCollectionView {
    CGFloat cellWidth = (self.view.bounds.size.width - (2 * kMargin * ((CGFloat)kRowCount - 1))) / (CGFloat)kRowCount;
    CGSize targetSize = CGSizeMake(cellWidth, cellWidth);
    

    CGRect collectionViewFrame = CGRectMake(self.view.bounds.origin.x,
                                            self.view.bounds.origin.y +
                                            self.navigationController.navigationBar.frame.size.height +
                                            self._statusBarHeight,
                                            self.view.bounds.size.width,
                                            cellWidth + 2 * kMargin);
    self.collectionView.frame = collectionViewFrame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = targetSize;
    layout.minimumLineSpacing = kMargin;
    layout.minimumInteritemSpacing = kMargin;
    layout.sectionInset = UIEdgeInsetsMake(kMargin,
                                           kMargin,
                                           kMargin,
                                           kMargin);
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = YES;
    
    [self.view addSubview:self.collectionView];
}

- (void)_setupTitleTextField {
    CGRect titleTextViewFrame = CGRectMake(self.collectionView.frame.origin.x + kMargin * 2,
                                           self.collectionView.frame.origin.y +
                                           self.collectionView.frame.size.height + kMargin,
                                           self.view.bounds.size.width - kMargin * 4,
                                           self.view.bounds.size.height / 14);
    self.titleTextField.frame = titleTextViewFrame;
    CALayer *bottomLine = [CALayer layer];
    bottomLine.frame = CGRectMake(0.0f, self.titleTextField.frame.size.height - 1, self.titleTextField.frame.size.width, kBorderWidth);
    bottomLine.backgroundColor = UIColor.grayColor.CGColor;
    [self.titleTextField setBorderStyle:UITextBorderStyleNone];
    [self.titleTextField.layer addSublayer:bottomLine];
    [self.view addSubview:self.titleTextField];
}

- (void)_setupDescriptionTextField {
    CGRect descriptionTextFieldFrame = CGRectMake(self.titleTextField.frame.origin.x,
                                                  self.titleTextField.frame.origin.y +
                                                  self.titleTextField.frame.size.height + kMargin,
                                                  self.view.bounds.size.width - kMargin * 4,
                                                  self.view.bounds.size.height / 14);
    self.descriptionTextField.frame = descriptionTextFieldFrame;
    CALayer *bottomLine = [CALayer layer];
    bottomLine.frame = CGRectMake(0.0f, self.descriptionTextField.frame.size.height - 1, self.descriptionTextField.frame.size.width, kBorderWidth);
    bottomLine.backgroundColor = UIColor.grayColor.CGColor;
    [self.descriptionTextField setBorderStyle:UITextBorderStyleNone];
    [self.descriptionTextField.layer addSublayer:bottomLine];
    [self.view addSubview:self.descriptionTextField];
}

- (void)_setupAlbumSelectorButton {
    CGRect albumSelectorButtonFrame = CGRectMake(self.descriptionTextField.frame.origin.x,
                                                 self.descriptionTextField.frame.origin.y +
                                                 self.descriptionTextField.frame.size.height + kMargin,
                                                 self.view.bounds.size.width - kMargin * 4,
                                                 self.view.bounds.size.height / 14);
    self.albumSelectorButton.frame = albumSelectorButtonFrame;
    CALayer *bottomLine = [CALayer layer];
    bottomLine.frame = CGRectMake(0.0f, self.descriptionTextField.frame.size.height - 1, self.albumSelectorButton.frame.size.width, kBorderWidth);
    bottomLine.backgroundColor = UIColor.grayColor.CGColor;
    [self.albumSelectorButton.layer addSublayer:bottomLine];
    self.albumSelectorButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    self.albumSelectorButton.configuration.contentInsets = NSDirectionalEdgeInsetsMake(0, 10, 0, 0);
    [self.albumSelectorButton setTitleColor:UIColor.grayColor
                                   forState:UIControlStateNormal];
    [self.albumSelectorButton addTarget:self
                                 action:@selector(_onAlbumSelectorClicked)
                       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.albumSelectorButton];
    
    [self _toggleAlbumSelectorTitle];
}

- (void)_onAlbumSelectorClicked {
    AlbumPickerViewController *albumPickerVC = [[AlbumPickerViewController alloc] init];
    albumPickerVC.delegate = self;
    [self.navigationController pushViewController:albumPickerVC animated:YES];
}

- (void)_toggleAlbumSelectorTitle {
    if (self.selectedAlbumInfo) {
        [self.albumSelectorButton setTitleColor:UIColor.blackColor
                                       forState:UIControlStateNormal];
        [self.albumSelectorButton setTitle:self.selectedAlbumInfo.albumName
                                  forState:UIControlStateNormal];
    } else {
        [self.albumSelectorButton setTitleColor:UIColor.grayColor
                                       forState:UIControlStateNormal];
        [self.albumSelectorButton setTitle:NSLocalizedString(@"Browse album placeholder", nil)
                                  forState:UIControlStateNormal];
    }
}

- (CGFloat)_statusBarHeight {
    UIWindowScene * scene = nil;
    for (UIWindowScene* wScene in [UIApplication sharedApplication].connectedScenes){
        if (wScene.activationState == UISceneActivationStateForegroundActive){
            scene = wScene;
            break;
        }
    }
    CGFloat statusBarHeight = scene.statusBarManager.statusBarFrame.size.height;
    return statusBarHeight;
}

#pragma mark - Handlers

- (void)_onPostButtonClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *titleText = self.titleTextField.text;
    NSString *descriptionText = self.descriptionTextField.text;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [self.uploadPhotoManager uploadSelectedImages:self.assets
                                            withTitle:titleText
                                          description:descriptionText
                                              albumID:self.selectedAlbumInfo.albumID];
    });
}

/*
- (void)uploadImageExample {
    [self uploadImageExampleWithImageName:@"Server Icon"
                         imageDescription:@"A small icon for displaying info"
                          imageAssetsName:@"ic_server_error"];
    [self uploadImageExampleWithImageName:@"Dynamic Layout icon"
                         imageDescription:@"A small icon for showing dynamic layout"
                          imageAssetsName:@"ic_dynamic_layout"];
    [self uploadImageExampleWithImageName:@"Fixed Layout Icon"
                         imageDescription:@"A small icon for displaying fixed layout icon"
                          imageAssetsName:@"ic_fixed_layout"];
}

- (void)uploadImageExampleWithImageName:(NSString *)imageName
                       imageDescription:(NSString *)description
                        imageAssetsName:(NSString *)named {
    UIImage *imageExample = [UIImage imageNamed:named];
    
    [self.uploadPhotoManager uploadUserImage:imageExample
                                       title:imageName
                                 description:description
                           completionHandler:^(NSString * _Nullable photoName,
                                                NSError * _Nullable error) {
        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            switch (error.code) {
                case kNetworkError:
                    // Network error view
                    NSLog(@"[DEBUG] %s : No internet connection", __func__);
                    break;
                case kNoDataError:
                    // No data error view
                    NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                    break;
                default:
                    // Error occur view
                    NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                    break;
            }
            return;
        }
        
        NSLog(@"[DEBUG] %s: Photo name uploaded: %@", __func__, photoName);
    }];
}
*/

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count > kNumberOfPhotosToDisplay? kNumberOfCellsToDisplay : self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == kLastIndex) {
        RemainingPhotosNumberCollectionViewCell *cell = [collectionView
                                                         dequeueReusableCellWithReuseIdentifier:RemainingPhotosNumberCollectionViewCell.reuseIdentifier
                                                         forIndexPath:indexPath];
        remainingPhotos = self.assets.count - kNumberOfPhotosToDisplay;
        [cell configureWithNumberOfPhotos:remainingPhotos];
        return cell;
    } else {
        GalleryCollectionViewCell *cell = [collectionView
                                           dequeueReusableCellWithReuseIdentifier:GalleryCollectionViewCell.reuseIdentifier
                                           forIndexPath:indexPath];
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        PHAsset *photoAsset = [self.assets objectAtIndex:indexPath.item];
        cell.photoAssetIdentifier = photoAsset.localIdentifier;
        [self.galleryManager.imageCacheManager requestImageForAsset:photoAsset
                                                         targetSize:kTargetSize
                                                        contentMode:PHImageContentModeAspectFill
                                                            options:nil
                                                      resultHandler:^(UIImage * _Nullable result,
                                                                      NSDictionary * _Nullable info) {
            if ([cell.photoAssetIdentifier isEqualToString:photoAsset.localIdentifier]) {
                [cell configureWithImage:result];
            }
        }];
        return cell;
    }
}

#pragma mark - AlbumPickerDelegate

- (void)onFinishSelectAlbumInfo:(AlbumInfo *)selectedAlbumInfo {
    if (selectedAlbumInfo) {
        self.selectedAlbumInfo = selectedAlbumInfo;
        [self _toggleAlbumSelectorTitle];
    }
}

#pragma mark - Custom accessors
//- (UploadPhotoManager *)uploadPhotoManager {
//    if (_uploadPhotoManager) return _uploadPhotoManager;
//    _uploadPhotoManager = [[UploadPhotoManager alloc] init];
//    return _uploadPhotoManager;
//}

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
   
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:layout];

    [_collectionView registerClass:[GalleryCollectionViewCell class]
        forCellWithReuseIdentifier:GalleryCollectionViewCell.reuseIdentifier];
    [_collectionView registerClass:[RemainingPhotosNumberCollectionViewCell class]
        forCellWithReuseIdentifier:RemainingPhotosNumberCollectionViewCell.reuseIdentifier];
   
    return _collectionView;
}

- (TitleTextField *)titleTextField {
    if (_titleTextField) return _titleTextField;
    
    _titleTextField = [[TitleTextField alloc] init];
    return _titleTextField;
}

- (DescriptionTextField *)descriptionTextField {
    if (_descriptionTextField) return _descriptionTextField;
    
    _descriptionTextField = [[DescriptionTextField alloc] init];
    return _descriptionTextField;
}

- (UIButton *)albumSelectorButton {
    if (_albumSelectorButton) return _albumSelectorButton;
    
    _albumSelectorButton = [[UIButton alloc] init];
    return _albumSelectorButton;
}

- (NSArray<PHAsset *> *)assets {
    if (_assets) return _assets;
    _assets = [NSArray array];
    _assets = [self.selectedAssets allValues];
    return _assets;
}

@end
