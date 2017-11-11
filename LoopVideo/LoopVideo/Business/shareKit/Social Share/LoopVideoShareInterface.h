//
//  LoopVideoShareInterface.h
//  LoopVideo
//
//  Created by hend elsisi on 10/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"
#import "SocialOperations.h"
#import "LoopVideoFbShareInterface.h"
@protocol callBackDelegat;
@interface LoopVideoShareInterface : NSObject<fbUploadVideoDelegate>
+ (LoopVideoShareInterface *)sharedLoopSharer;
@property (nonatomic, strong) id<callBackDelegat> delegate;

-(void)fbshare:(NSString*)caption andShareType:(ShareType)type andDelegate:(id<fbUploadVideoDelegate>)delegate andVideoData:(NSData*)videoData andIdentifier:(NSString*)vid;
-(void)InstshareToUrl:(NSString*)url;
-(void)shareGig:(NSString*)shareLink;

@end
@protocol callBackDelegat
-(void)uploadSuccess;
-(void)uploadFailed;
@end
