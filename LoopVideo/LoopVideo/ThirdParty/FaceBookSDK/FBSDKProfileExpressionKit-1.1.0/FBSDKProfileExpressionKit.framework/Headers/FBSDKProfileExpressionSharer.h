// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class FBSDKProfileExpressionSharer

 @abstract
 The FBSDKProfileExpressionSharer is used to share media from apps into Facebook profile. The underlying
 mechanism used to share data between apps is UIPasteboard or camera roll

 @discussion
 - FacebookAppID must be set in the your app's Info.plist with the Facebook App Id
 - Any existing data in the system's public pasteboard will get overwritten with the shared media
 - Once the data is shared in Facebook, the pasteboard with be cleared
 - The following strings need to be translated in your app:
    NSLocalizedString(@"Get Facebook", @"Alert title telling a user they need to install Facebook")
    NSLocalizedString(@"You'll need to install the latest version of Facebook to share this.", @"Alert message when an old version of Facebook is installed")
    NSLocalizedString(@"Not Now", @"Button label when user doesn't want to install Facebook")
    NSLocalizedString(@"Install", @"Button label to install Facebook")
    NSLocalizedString(@"Share", @"Button label for sharing content")
  - LSApplicationQueriesSchemes must be defined in your app's Info.plist with an entry for fb-profile-expression-platform eg:
      <key>LSApplicationQueriesSchemes</key>
      <array>
      <string>fb-profile-expression-platform</string>
      </array>
 */
@interface FBSDKProfileExpressionSharer : NSObject

/*!
 @abstract
 Call this method to determine if the app has been launched from Facebook to create profile media.

 @discussion returns YES if the app was launched from Facebook. You should call this method to
 determine whether to return straight back to Facebook after recording a video or image in your app.

  This method will only work if you call [FBSDKProfileExpressionURLHandler parseIncomingURL:] from your AppDelegates application:openURL:options method.
 */
+ (BOOL)wasLaunchedFromFacebook;


/*!
 @abstract
 Call this method to determine if a version of Facebook is installed that supports profile media uploads

 @discussion returns NO if Facebook isn't installed, or if the version installed isn't new enough to support profile video uploads
 */
+ (BOOL)isProfileMediaUploadAvailable;


/*!
 @abstract
 Call this method to open Facebook and upload a profile video.

 @discussion
 Note that there's no way to send an AVAsset between apps, so you may need to
 serialize your AVAsset to a file, and get an NSData representation of the video via
 [NSData dataWithContentsOfFile:filepath];

 @param videoData The profile video to be uploaded to Facebook

 @param metadata an optional dictionary of metadata to send to the facebook app

 @discussion If there is not an installed version of Facebook on the device that supports profile video upload, an alert will be presented to the user to go to the App Store to install the latest version of Facebook
 */
+ (void)uploadProfileVideoFromData:(NSData *)videoData metadata:(NSDictionary *)metadata;

/*!
 @abstract
 Call this method to open Facebook and upload a profile video.

 @param localIdentifier ALAssetLibrary or PhotoKit identifier for video in camera roll to upload to facebook.
 For an ALAsset use ALAsset.defaultRepresentation.url.absoluteString
 For a PHAsset use PHAsset.localIdentifier

 @param metadata an optional dictionary of metadata to send to the Facebook app

 @discussion If there is not an installed version of Facebook on the device that supports the share, an alert will be presented to the user to go to the App Store to install the latest version of Facebook
 */
+ (void)uploadProfileVideoWithLocalIdentifier:(NSString *)localIdentifier metadata:(NSDictionary *)metadata;

/*!
 @abstract
 Call this method to open Facebook and upload a profile picture.

 @param imageData The profile image to be uploaded to Facebook

 @param metadata an optional dictionary of metadata to send to the Facebook app

 @discussion If there is not an installed version of Facebook on the device that supports profile video upload, an alert will be presented to the user to go to the App Store to install the latest version of Facebook
 */
+ (void)uploadProfilePictureFromData:(NSData *)imageData metadata:(NSDictionary *)metadata;

/*!
 @abstract
 Call this method to open Facebook and upload a profile picture.

 @param image The profile image to be uploaded to Facebook

 @param metadata an optional dictionary of metadata to send to the Facebook app

 @discussion If there is not an installed version of Facebook on the device that supports profile video upload, an alert will be presented to the user to go to the App Store to install the latest version of Facebook
 */
+ (void)uploadProfilePictureFromUIImage:(UIImage *)image metadata:(NSDictionary *)metadata;

/*!
 @abstract
 Call this method to open Facebook and upload a profile picture.

 @discussion
 Note that there's no way to send an AVAsset between apps, so you may need to
 serialize your AVAsset to a file, and get an NSData representation of the video via
 [NSData dataWithContentsOfFile:filepath];

 @param localIdentifier ALAssetLibrary or PhotoKit identifier for video in camera roll to upload to facebook.
 For an ALAsset use ALAsset.defaultRepresentation.url.absoluteString
 For a PHAsset use PHAsset.localIdentifier

 @param metadata an optional dictionary of metadata to send to the Facebook app

 @discussion If there is not an installed version of Facebook on the device that supports the share, an alert will be presented to the user to go to the App Store to install the latest version of Facebook
 */
+ (void)uploadProfilePictureWithLocalIdentifier:(NSString *)localIdentifier metadata:(NSDictionary *)metadata;

@end
