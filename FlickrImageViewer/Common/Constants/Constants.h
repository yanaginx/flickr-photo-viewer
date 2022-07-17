//
//  Constants.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#ifndef Constants_h
#define Constants_h

// Password
// ZU?Gu?6GX?$+x)e

#define kButtonMargin 50
#define kFrameHeight 60
#define kFrameWidth 200

#define kConsumerKey @"68fb93124728e9d210ca6dd75e1ba96d"
#define kConsumerSecret @"b55ec59d57a6e559"
#define kCallbackURL @"flickrz://"
#define kAuthorizationEndpoint @"https://www.flickr.com/services/oauth/authorize"
#define kOAuthHost @"www.flickr.com/services/oauth"

//#define kPopularUserID @"69522958@N04"
#define kPopularUserID @"72489705@N00"
//#define kPopularUserID @"27420180@N08"

#define kBigSizeSuffix @"b"
#define kSmallSizeSuffix @"w"
#define kMargin 3
#define kCellHeight 200
#define kNetworkError 150900
#define kServerError 150901
#define kNoDataError 150902
#define kNoError 0
#define kLastPhotoUploaded 1615

#define kIsFixedHeight YES
#define kMaxRowHeight 200
#define kValidRatio 3.0

#define kAPIEndpoint @"api.flickr.com/services/rest/"
#define kPublicPhotosMethod @"flickr.people.getPublicPhotos"
#define kUserProfileMethod @"flickr.people.getInfo"
#define kPopularPhotosMethod @"flickr.photos.getPopular"
#define kRecentPhotosMethod @"flickr.photos.getRecent"
#define kGetAlbumInfosMethod @"flickr.photosets.getList"
#define kGetAlbumDetailPhotosMethod @"flickr.photosets.getPhotos"
#define kAddPhotoToPhotosetMethod @"flickr.photosets.addPhoto"
#define kCallbackURLScheme @"flickrz"

#define kUploadEndpoint @"up.flickr.com/services/upload/"
#define kUploadIsPublic @"1"

#define kIsNoJSONCallback @"1"
#define kResponseFormat @"json"
#define kResultsPerPage @"20"

#define kPostBoundary @"---------------------------14737809831466499882746641449"

#define kTargetSize CGSizeMake(200, 200)

#define kAppleBlueAlpha [UIColor colorWithRed:14.0/255 green:122.0/255 blue:254.0/255 alpha:0.5]
#define kAppleBlue [UIColor colorWithRed:14.0/255 green:122.0/255 blue:254.0/255 alpha:1.0]

#endif
