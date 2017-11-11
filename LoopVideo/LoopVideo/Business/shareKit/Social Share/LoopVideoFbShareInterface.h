//
//  LoopVideoFbShareInterface.h
//  LoopVideo
//
//  Created by hend elsisi on 10/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialOperations.h"
#import "LoopVideoFbShare.h"
#import "Header.h"
@protocol fbUploadVideoDelegate;
@interface LoopVideoFbShareInterface : NSObject<SocialOperations>

- (id)initWithSocialType:(ShareType )fbShare;
- (id)initWithSocialType:(ShareType )fbShare andLinkPath:(NSString*)link;

- (id)initWithSocialType:(ShareType )fbShare andDelegate:(id<fbUploadVideoDelegate>) delegate andCaption:(NSString*)caption andVideoData:(NSData*) videoData andIdentifier:(NSString*)Id;

@property (nonatomic, strong) id<fbUploadVideoDelegate> delegate;
@property NSString* caption;
@property NSData* videoData;
@property NSString*vid;
@property NSString*linkPath;
@end

@protocol fbUploadVideoDelegate
-(void)fbUploadVideoDelegateDidSuccess;
-(void)fbUploadVideoDelegateDidFailed;
@end
