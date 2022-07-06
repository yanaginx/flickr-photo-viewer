//
//  UploadPostViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import "UploadPostViewController.h"
#import "Handlers/UploadPhotoManager.h"
#import "../../../Common/Constants/Constants.h"

@interface UploadPostViewController ()

@property (nonatomic, strong) UploadPhotoManager *uploadPhotoManager;

@end

@implementation UploadPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupTitle];
    [self setupPostButton];
}

#pragma mark - Operations
- (void)setupTitle {
    self.navigationItem.title = @"New Post";
}

- (void)setupPostButton {
     UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(uploadImageExample)];
    [self.navigationItem setRightBarButtonItem:postButton];
}

#pragma mark - Handlers

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
    
    [self.uploadPhotoManager  uploadUserImage:imageExample
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


#pragma mark - Custom accessors
- (UploadPhotoManager *)uploadPhotoManager {
    if (_uploadPhotoManager) return _uploadPhotoManager;
    _uploadPhotoManager = [[UploadPhotoManager alloc] init];
    return _uploadPhotoManager;
}

@end
