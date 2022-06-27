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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.cyanColor;
    
    [PopularPhotoManager.sharedPopularPhotoManager getPopularPhotoWithCompletionHandler:^(NSMutableArray<Photo *> * _Nullable photos,
                                                                                          NSError * _Nullable error) {
        if (error) {
            NSLog(@"[DEBUG] %s : error: %@",
                  __func__,
                  error.localizedDescription);
        }
    }];
}


@end
