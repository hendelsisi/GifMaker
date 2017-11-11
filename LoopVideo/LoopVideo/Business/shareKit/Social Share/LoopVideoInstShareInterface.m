//
//  LoopVideoInstShareInterface.m
//  LoopVideo
//
//  Created by hend elsisi on 10/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "LoopVideoInstShareInterface.h"
#import "SCInstagram.h"
@implementation LoopVideoInstShareInterface

- (id)initWithSocialType:(NSString* )url{

    self = [super init];
    if (self) {
        self.appUrl = url;
    }
    return self;



}
-(void)shareVideo{

    [SCInstagram loadCameraRollAssetToInstagram:_appUrl];
}

-(void)shareGifImage{

}

@end
