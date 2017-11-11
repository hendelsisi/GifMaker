//
//  LoopVideoInstShareInterface.h
//  LoopVideo
//
//  Created by hend elsisi on 10/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialOperations.h"
@interface LoopVideoInstShareInterface : NSObject<SocialOperations>
@property NSString* appUrl;
- (id)initWithSocialType:(NSString* )url;
@end
