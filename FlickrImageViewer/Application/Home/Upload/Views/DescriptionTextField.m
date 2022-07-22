//
//  DescriptionTextField.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 08/07/2022.
//

#import "DescriptionTextField.h"

@implementation DescriptionTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:UIColor.grayColor
                                                               forKey:NSForegroundColorAttributeName];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Description placeholder", nil)
                                                                     attributes:attributes];
    }
    return self;
}

@end
