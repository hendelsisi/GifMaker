//
//  LoopVideoFbShare.h
//  trySCFacebook
//
//  Created by hend elsisi on 10/4/16.
//  Copyright © 2016 hend elsisi. All rights reserved.
//

#import "SCFacebook.h"

@interface LoopVideoFbShare : SCFacebook

+(void)initLoop;
+(void)sendFbMessage:(NSData*)videoData;
+(void)changeProfilePic:(NSString*)videoData;

@end
