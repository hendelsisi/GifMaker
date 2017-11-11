//
//  SCInstagram.m
//  LoopVideo
//
//  Created by hend elsisi on 10/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "SCInstagram.h"
#import <UIKit/UIKit.h>
@implementation SCInstagram

+ (void)loadCameraRollAssetToInstagram:(NSString*)assetsLibraryURL{
    
    NSURL *instagramURL       = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", assetsLibraryURL]];
    NSURL *instagramAppURL = [NSURL URLWithString:@"https://itunes.apple.com/in/app/instagram/id389801252?m"];
   
     if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://user"] ])
     
     [[UIApplication sharedApplication] openURL:instagramURL];
   
    else
      [[UIApplication sharedApplication] openURL:instagramAppURL];
   
}

@end
