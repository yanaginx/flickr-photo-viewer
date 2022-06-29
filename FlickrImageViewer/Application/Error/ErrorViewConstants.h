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

#define kLabelMargin (self.view.frame.size.width / 5)
#define kButtonMargin (self.view.frame.size.width / 3)

#define kImageHeight (self.view.frame.size.height / 5)
#define kImageWidth (self.view.frame.size.height / 5)

#define kButtonHeight (kImageHeight / 4)
#define kButtonWidth (self.view.frame.size.width - (kButtonMargin * 2))

#define kLabelHeight (kImageHeight / 2)
#define kLabelWidth (self.view.frame.size.width - (kLabelMargin * 2))

#define kLabelX (self.view.center.x - kLabelWidth / 2)
#define kLabelY (self.view.center.y - kLabelHeight / 2)

#define kImageX (self.view.center.x - kImageWidth / 2)
//#define kImageY (self.view.center.y - (kSpacing + kLabelY + kImageHeight))
#define kImageY (self.view.center.y - (kImageHeight + kSpacing))

#define kButtonX (self.view.center.x - kButtonWidth / 2)
#define kButtonY (self.view.center.y + kSpacing)


#endif /* ErrorViewConstants_h */
