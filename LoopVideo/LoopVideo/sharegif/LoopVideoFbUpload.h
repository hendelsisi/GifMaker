//
//  trySwiftFacebook.h
//  trySwiftUpload
//
//  Created by hend elsisi on 9/29/16.
//  Copyright © 2016 hend elsisi. All rights reserved.
//

#import "Facebook.h"

@interface LoopVideoFbUpload : Facebook
+ (LoopVideoFbUpload *)sharedInstance;
- (FBRequest*)openUrl:(NSString *)url
               params:(NSMutableDictionary *)params
           httpMethod:(NSString *)httpMethod
             delegate:(id<FBRequestDelegate>)delegate;
- (BOOL)handleOpenURL:(NSURL *)url;

@property bool fail;
@property int count;
@end
