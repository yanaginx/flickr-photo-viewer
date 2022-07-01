//
//  ErrorViewConstants.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 29/06/2022.
//

#ifndef ErrorViewConstants_h
#define ErrorViewConstants_h

#define kOneTenthOfViewHeight (self.view.frame.size.height / 10)
#define kOneFifthOfViewHeight (self.view.frame.size.height / 5)

#define kSpacing self.view.frame.size.height / 20

#define kCenterX (self.view.frame.size.width / 2)
#define kCenterY (self.view.frame.size.height / 2)

#define kLabelMargin (self.view.frame.size.width / 5)
#define kButtonMargin (self.view.frame.size.width / 3)

#define kImageHeight (self.view.frame.size.height / 5)
#define kImageWidth (self.view.frame.size.height / 5)

#define kButtonHeight ((kImageHeight / 4) >= 44 ? (kImageHeight / 4) : 44)
#define kButtonWidth (self.view.frame.size.width - (kButtonMargin * 2))

#define kLabelHeight (kImageHeight / 2)
#define kLabelWidth (self.view.frame.size.width - (kLabelMargin * 2))

#define kLabelX (kCenterX - kLabelWidth / 2)
#define kLabelY (kCenterY - kLabelHeight / 2)

#define kImageX (kCenterX - kImageWidth / 2)
//#define kImageY (self.view.center.y - (kSpacing + kLabelY + kImageHeight))
#define kImageY (kCenterY - (kImageHeight + kSpacing))

#define kButtonX (kCenterX - kButtonWidth / 2)
#define kButtonY (kCenterY + kSpacing)


#endif /* ErrorViewConstants_h */
