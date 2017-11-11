//
//  trySwiftFacebook.m
//  trySwiftUpload
//
//  Created by hend elsisi on 9/29/16.
//  Copyright © 2016 hend elsisi. All rights reserved.
//

#import "LoopVideoFbUpload.h"


static NSString* kSDK = @"ios";
static NSString* kSDKVersion = @"2";

@implementation LoopVideoFbUpload

+ (LoopVideoFbUpload *)sharedInstance{

    static dispatch_once_t once;
    static LoopVideoFbUpload *instance;
    dispatch_once(&once, ^{
        instance = [[LoopVideoFbUpload alloc] initWithAppId:@"330238987309395"];
        instance.fail = false;
        instance.count = 0;
        
       
    });
    return instance;


}
- (FBRequest*)openUrl:(NSString *)url
               params:(NSMutableDictionary *)params
           httpMethod:(NSString *)httpMethod
             delegate:(id<FBRequestDelegate>)delegate{
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_fb_logged_in"])
        return [super openUrl:url params:params httpMethod:httpMethod delegate:delegate];
    else
        
    {
        [params setValue:@"json" forKey:@"format"];
        [params setValue:kSDK forKey:@"sdk"];
        [params setValue:kSDKVersion forKey:@"sdk_version"];
      
            [params setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] forKey:@"access_token"];
        
        _request = [FBRequest getRequestWithParams:params
                                         httpMethod:httpMethod
                                           delegate:delegate
                                         requestURL:url];
        [_request connect];
        return _request;
    
    }

}



- (BOOL)handleOpenURL:(NSURL *)url{
       NSString *query = [url fragment];
    
    // Version 3.2.3 of the Facebook app encodes the parameters in the query but
    // version 3.3 and above encode the parameters in the fragment. To support
    // both versions of the Facebook app, we try to parse the query if
    // the fragment is missing.
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [self parseURLParams:query];
    NSString *accessToken = [params valueForKey:@"access_token"];
[[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
    NSString *expTime = [params valueForKey:@"expires_in"];
    NSDate *expirationDate = [NSDate distantFuture];
    if (expTime != nil) {
        int expVal = [expTime intValue];
        if (expVal != 0) {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"expiration_Date"];
    
    return [super handleOpenURL:url];
    
}
@end
