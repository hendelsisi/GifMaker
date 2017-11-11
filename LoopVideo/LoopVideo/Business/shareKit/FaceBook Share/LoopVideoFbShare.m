//
//  LoopVideoFbShare.m
//  trySCFacebook
//
//  Created by hend elsisi on 10/4/16.
//  Copyright © 2016 hend elsisi. All rights reserved.
//

#import "LoopVideoFbShare.h"
#import "SCFacebook.h"
#import "FBSDKMessengerSharer.h"
@import FBSDKProfileExpressionKit;

@implementation LoopVideoFbShare

+(void)initLoop {
        [SCFacebook initWithReadPermissions:@[@"user_about_me",
                                              @"user_birthday",
                                              @"email",
                                              @"user_photos",
                                              @"user_events",
                                              @"user_friends",
                                              @"user_videos",
                                              @"public_profile"]
                         publishPermissions:@[@"manage_pages",
                                              @"publish_actions",
                                              @"publish_pages"]
         ];
        
        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
}

+(void)sendFbMessage:(NSData*)videoData{
   [FBSDKMessengerSharer shareVideo:videoData withOptions:nil];
}

+(BOOL)isSessionValid
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_fblogin"];
}
+(void)changeProfilePic:(NSString*)videoData{
    [ FBSDKProfileExpressionSharer uploadProfileVideoWithLocalIdentifier: videoData metadata: nil];
}
@end
