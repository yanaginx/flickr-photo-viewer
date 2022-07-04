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

#define kConsumerKey @"68fb93124728e9d210ca6dd75e1ba96d"
#define kConsumerSecret @"b55ec59d57a6e559"
#define kCallbackURL @"flickrz://"
#define kAuthorizationEndpoint @"https://www.flickr.com/services/oauth/authorize"
#define kOAuthHost @"www.flickr.com/services/oauth"

//#define kPopularUserID @"69522958@N04"
#define kPopularUserID @"72489705@N00"
#define kUserNSID LoginHandler.sharedLoginHandler.userNSID
//#define kPopularUserID @"27420180@N08"

#define kBigSizeSuffix @"b"
#define kSmallSizeSuffix @"w"
#define kMargin 6
#define kCellHeight 200
#define kNetworkError 150900
#define kServerError 150901
#define kNoDataError 150902

#define kIsFixedHeight YES
#define kMaxRowHeight 200
#define kValidRatio 3.0

#define kAPIEndpoint @"api.flickr.com/services/rest/"
#define kPublicPhotosMethod @"flickr.people.getPublicPhotos"
#define kUserProfileMethod @"flickr.people.getInfo"
#define kPopularPhotosMethod @"flickr.photos.getPopular"
#define kGetAlbumInfosMethod @"flickr.photosets.getList"
#define kGetAlbumDetailPhotosMethod @"flickr.photosets.getPhotos"
#define kCallbackURLScheme @"flickrz"

#define kIsNoJSONCallback @"1"
#define kResponseFormat @"json"
#define kResultsPerPage @"20"

#endif
