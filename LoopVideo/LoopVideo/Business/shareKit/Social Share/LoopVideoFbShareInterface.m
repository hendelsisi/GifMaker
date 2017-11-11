//
//  LoopVideoFbShareInterface.m
//  LoopVideo
//
//  Created by hend elsisi on 10/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "LoopVideoFbShareInterface.h"


@interface LoopVideoFbShareInterface ()

@property  ShareType fbShare;

@end

@implementation LoopVideoFbShareInterface
- (id)initWithSocialType:(ShareType )fbShare{

    self = [super init];
    if (self) {
        self.fbShare = fbShare;
    }
    return self;
}

- (id)initWithSocialType:(ShareType )fbShare andLinkPath:(NSString*)link{
    self = [super init];
    if (self) {
        self.fbShare = fbShare;
        self.linkPath = link;
    }
    return self;

}

- (id)initWithSocialType:(ShareType )fbShare andDelegate:(id<fbUploadVideoDelegate>) delegate andCaption:(NSString*)caption andVideoData:(NSData*) videoData andIdentifier:(NSString*)Id{
    self = [super init];
    if (self) {
        self.fbShare = fbShare;
        self.delegate = delegate;
        self.caption = caption;
        self.videoData = videoData;
        self.vid = Id;
    }
    return self;
}

-(void)shareVideo{
    
  //  NSData *videoData = [NSData dataWithContentsOfURL:_videourl];
    
    if (_fbShare == WallPost) {
        [LoopVideoFbShare feedPostWithVideo:_videoData title:@"Loop Video" description:_caption callBack:^(BOOL success, id result) {
            if (success) {
                [self.delegate fbUploadVideoDelegateDidSuccess];
            } else {
                [self.delegate fbUploadVideoDelegateDidFailed];
            }
            
        }];
       
    } else if(_fbShare == Messenger) {
        NSLog(@"here");
     //   NSLog(@"wef %@",_videourl.absoluteString);
        [LoopVideoFbShare sendFbMessage:_videoData];
        
    }
    else if(_fbShare == ProfilePic) {
        [LoopVideoFbShare changeProfilePic:_vid];
        
    }
}

-(void)shareGifImage{
   
}

@end
