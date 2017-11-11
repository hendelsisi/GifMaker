//
//  theTrime.m
//  LoopVideo
//
//  Created by hend elsisi on 10/13/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "theTrime.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@implementation theTrime
-(void)trime
{
//   float startTime = 15.099;
//   float stopTime = 20.23455;
//    
//    [self deleteTmpFile];
//    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
//        
//        NSURL* videoFileUrl = [(AVURLAsset*)avAsset URL];
//        AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
//        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
//        if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
//            
//            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
//                                  initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
//            // Implementation continues.
//            
//            NSURL *furl = [NSURL fileURLWithPath:self.tmpVideoPath];
//            
//            exportSession.outputURL = furl;
//            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//            
//            CMTime start = CMTimeMakeWithSeconds(startTime, anAsset.duration.timescale);
//            CMTime duration = CMTimeMakeWithSeconds(stopTime-self.startTime, anAsset.duration.timescale);
//            CMTimeRange range = CMTimeRangeMake(start, duration);
//            exportSession.timeRange = range;
//            
//            [exportSession exportAsynchronouslyWithCompletionHandler:^{
//                
//                switch ([exportSession status]) {
//                    case AVAssetExportSessionStatusFailed:
//                        NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
//                        break;
//                    case AVAssetExportSessionStatusCancelled:
//                        NSLog(@"Export canceled");
//                        break;
//                    default:
//                        NSLog(@"NONE");
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            
//                            //[self playMovie:self.tmpVideoPath];
//                            
//                            NSLog(@"finish");
//                            [self fetchAndCreateAlbum];
//                            [self saveNewVideoToCameraRoll:[NSURL fileURLWithPath:_tmpVideoPath]];
//                            // UISaveVideoAtPathToSavedPhotosAlbum(self.tmpVideoPath, self, nil, nil);
//                            
//                        });
//                        
//                        break;
//                }
//            }];
//            
//        }
//        
//    }];
}

-(void)deleteTmpFile{
    NSString *tempDir = NSTemporaryDirectory();
    NSString* tmpVideoPath = [tempDir stringByAppendingPathComponent:@"tmpMov.mov"];
    
    NSURL *url = [NSURL fileURLWithPath:tmpVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}


@end
