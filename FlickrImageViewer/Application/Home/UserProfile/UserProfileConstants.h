//
//  UserProfileConstants.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#ifndef UserProfileConstants_h
#define UserProfileConstants_h

#define kStatusBarHeight UIApplication.sharedApplication.statusBarFrame.size.height
#define kTabBarHeight self.tabBarController.tabBar.frame.size.height
#define kSpacing 20
#define kHeaderHeight 200
#define kSegmentedControlHeight 40
#define kHeaderBottomConstant -(self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - kHeaderHeight - kStatusBarHeight)
#define kSegmentedControlBottomConstant -(self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height- kHeaderHeight - kSegmentedControlHeight - kStatusBarHeight)

#define kAvatarSize 80
#define kAvatarX (self.view.center.x - kAvatarSize / 2)
#define kAvatarY (self.view.center.y - kTabBarHeight - kStatusBarHeight * 3 / 2)

#define kAvatarLead (self.view.frame.size.width / 2 - kAvatarSize / 2)
#define kAvatarTrail -(kAvatarLead)
#define kAvatarTop (self.view.frame.size.height / 3 - kAvatarSize / 3)
#define kAvatarBottom -(self.view.frame.size.height * 2 / 3 - kAvatarSize * 2 / 3)

#define kNameLabelBottom -(self.view.frame.size.height / 6)
#define kNumberOfPhotoBottom -(self.view.frame.size.height / 6)

#define kNameLabelWidth self.view.frame.size.width
#define kNameLabelHeight 40
#define kNameLabelX 0
#define kNameLabelY (self.view.center.y - kTabBarHeight * 3 / 4)

#define kNumberOfPhotoLabelWidth self.view.frame.size.width
#define kNumberOfPhotoLabelHeight 40
#define kNumberOfPhotoLabelX 0
#define kNumberOfPhotoLabelY (self.view.center.y - kAvatarSize / 2)

#define kSettingButtonMargin 10
#define kSettingButtonSize 30
#define kSettingButtonX (self.view.center.x + (self.view.frame.size.width / 2 - kSettingButtonMargin - kSettingButtonSize))
#define kSettingButtonY (self.view.center.y - self.view.frame.size.height)

#define kLayoutSegmentedControlHeight 35
#define kLayoutSegmentedControlWidth 120


#endif /* UserProfileConstants_h */
