//
//  FixedFlowLayout.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import "FixedFlowLayout.h"

@implementation FixedFlowLayout

static CGFloat itemSpacing = 6.0f;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumInteritemSpacing = itemSpacing;
    }
    return self;
}

@end
