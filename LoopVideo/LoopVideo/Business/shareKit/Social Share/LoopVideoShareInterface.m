//
//  LoopVideoShareInterface.m
//  LoopVideo
//
//  Created by hend elsisi on 10/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "LoopVideoShareInterface.h"

#import "LoopVideoInstShareInterface.h"

@interface LoopVideoShareInterface ()
@property (strong, nonatomic) id<SocialOperations> share;


@end

@implementation LoopVideoShareInterface
+ (LoopVideoShareInterface *)sharedLoopSharer{
    static dispatch_once_t once;
    static LoopVideoShareInterface *instance;
    dispatch_once(&once, ^{
        instance = [[LoopVideoShareInterface alloc] init];
    });
    return instance;

}


-(void)shareGig:(NSString*)shareLink{

    self.share = [[LoopVideoFbShareInterface alloc] initWithSocialType:Gif andLinkPath:shareLink];
    [self.share shareGifImage];
    
}

-(void)fbshare:(NSString*)caption andShareType:(ShareType)type andDelegate:(id<fbUploadVideoDelegate>)delegate andVideoData:(NSData*)videoData andIdentifier:(NSString *)vid{
    self.share = [[LoopVideoFbShareInterface alloc]initWithSocialType:type andDelegate:delegate andCaption:caption andVideoData:videoData andIdentifier:vid];
    [self.share shareVideo];
    
}
-(void)InstshareToUrl:(NSString*)url{

    self.share = [[LoopVideoInstShareInterface alloc]initWithSocialType:url];
    [self.share shareVideo];
}

-(void)fbUploadVideoDelegateDidSuccess{
    [self.delegate uploadSuccess];

}
-(void)fbUploadVideoDelegateDidFailed{
    [self.delegate uploadFailed];
}



@end
