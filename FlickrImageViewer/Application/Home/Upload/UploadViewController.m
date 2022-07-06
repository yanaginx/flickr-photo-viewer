//
//  UploadViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "UploadViewController.h"
#import "../../../Common/Constants/Constants.h"
#import "UploadPostViewController.h"

@interface UploadViewController ()

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupTitle];
    [self setupNextButton];
    [self setupDismissButton];
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
//    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc]
//                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                      primaryAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
//        [self dismiss];
//    }]];
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(dismiss)];
    [self.navigationItem setLeftBarButtonItem:dismissButton];
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

@end
