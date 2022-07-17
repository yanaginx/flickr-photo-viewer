//
//  FixedFlowLayout.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import "FixedFlowLayout.h"
#import "../../Constants/Constants.h"

@implementation FixedFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumInteritemSpacing = kMargin;
        self.minimumLineSpacing = 2 * kMargin;
    }
    return self;
}

@end
