//
//  UIViewController+AppOrientaion.m
//  LoopVideo
//
//  Created by hend elsisi on 12/6/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "UIViewController+AppOrientaion.h"

@implementation UIViewController (AppOrientaion)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSLog(@"werfef3");
    if([[NSUserDefaults standardUserDefaults]
        boolForKey:@"handleOrnWithoutNot"]){
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"handleOrnWithoutNot"];
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(orientation == UIInterfaceOrientationPortrait)
            //Do something if the orientation is in Portrait
            [[NSUserDefaults standardUserDefaults] setObject:@"else" forKey:@"Orn"];
        
        else if(orientation == UIInterfaceOrientationLandscapeLeft)
            [[NSUserDefaults standardUserDefaults] setObject:@"left" forKey:@"Orn"];
        // Do something if Left
        else if(orientation == UIInterfaceOrientationLandscapeRight)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"right" forKey:@"Orn"];
            NSLog(@"here");
        }
        
        else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
            [[NSUserDefaults standardUserDefaults] setObject:@"updown" forKey:@"Orn"];
        
        }
    
    return UIInterfaceOrientationMaskPortrait;
}



//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    NSLog(@"dsfweqfwer");
//    // Return YES for supported orientations
//    if (interfaceOrientation == UIInterfaceOrientationPortrait)
//    {
//     [[NSUserDefaults standardUserDefaults] setObject:@"else" forKey:@"Orn"];
//    }
//        
//        else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//        {
//         [[NSUserDefaults standardUserDefaults] setObject:@"right" forKey:@"Orn"];
//        }
//        else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
//        {
//           [[NSUserDefaults standardUserDefaults] setObject:@"left" forKey:@"Orn"];
//        }
//        else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//        {
//          [[NSUserDefaults standardUserDefaults] setObject:@"updown" forKey:@"Orn"];
//        }
//            
//    
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

@end
