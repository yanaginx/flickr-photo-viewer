//
//  PopularViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "PopularViewController.h"
#import "Handlers/PopularPhotoManager.h"

@interface PopularViewController ()

@end

@implementation PopularViewController

static NSInteger currentPage = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.cyanColor;
    
    [PopularPhotoManager.sharedPopularPhotoManager getPopularPhotoWithPage:currentPage
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
        
        for (NSURL *url in photos) {
            NSLog(@"[DEBUG] %s : photo URL: %@", __func__, url.absoluteString);
        }
    }];
}


@end
