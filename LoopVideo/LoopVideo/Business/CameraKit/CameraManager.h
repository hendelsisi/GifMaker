//
//  CameraManager.h
//  tryMakeMirror
//
//  Created by hend elsisi on 12/4/16.
//  Copyright © 2016 hend elsisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HWVideoButton.h"

@interface CameraManager : NSObject

@property IBOutlet HWVideoButton *btnVideo;
-(void)record:(id)sender;
-(void)disAppear;
+ (CameraManager *)sharedInstance;
-(void)load:(UIView*)view;
- (void)teardownAVCapture;
-(void)handleScreenRotation;
-(void)appear;
-(void)getCurrentScreenOrn;
-(void)toggleFlash;
@property BOOL isUsingTorchMood;
- (IBAction)switchCameras:(id)sender;
@end

