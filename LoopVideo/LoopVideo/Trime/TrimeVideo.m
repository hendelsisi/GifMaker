//
//  TrimeVideo.m
//  LoopVideo
//
//  Created by hend elsisi on 10/18/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "TrimeVideo.h"


@implementation TrimeVideo
-(void)trimeVideo:(myCompletion)compblock
{
//    self.startTime = 10.099;
//    self.stopTime = 20.23455;
    NSLog(@"start %f",self.startTime);
    NSString *tempDir = NSTemporaryDirectory();
    self.tmpVideoPath = [tempDir stringByAppendingPathComponent:@"tmpMov.mov"];
    [self deleteTmpFile];
//    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
    
        NSURL* videoFileUrl = [(AVURLAsset*)_requestedAsset URL];
        
          AVAsset *anAsset;
        if (_tempVideo != nil){
            anAsset = _tempVideo;
        }else{
        anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
        }
        
      //  AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
        
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
        if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
            
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                  initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
            // Implementation continues.
            
            NSURL *furl = [NSURL fileURLWithPath:self.tmpVideoPath];
            
            exportSession.outputURL = furl;
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            
            CMTime start = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);
            CMTime duration = CMTimeMakeWithSeconds(self.stopTime-self.startTime, anAsset.duration.timescale);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            exportSession.timeRange = range;
            NSLog(@"begin export");
            
          //  if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0 )
                //&&  [[[UIDevice currentDevice] systemVersion] doubleValue] < 10.2)
            {
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    NSLog(@"export");
                    switch ([exportSession status]) {
                        case AVAssetExportSessionStatusFailed:
                            NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                            break;
                        case AVAssetExportSessionStatusCancelled:
                            NSLog(@"Export canceled");
                            break;
                        default:
                            NSLog(@"NONE");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                compblock(YES,_tmpVideoPath);
                                NSLog(@"finish");
                            });
                            break;
                    }
                }];
            }
//            else{
//                NSLog(@"here");
//             compblock(YES,_tmpVideoPath);
//            }
        }
   // }];
}

-(void)saveNewVideoToCameraRoll:(NSURL*)vUrl andCallBack:(myCompletion)comp{
    [self setAssetCollection];
   
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         NSLog(@"Test vurl %@",vUrl);
        PHAssetChangeRequest* assetChangeRequest =
        
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:vUrl];
        PHObjectPlaceholder* assetplace= [assetChangeRequest placeholderForCreatedAsset];
        PHAssetCollectionChangeRequest* albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
        [albumChangeRequest addAssets:@[assetplace]];
       
        //
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //
        if(success)
             NSLog(@"saved");
       // comp(YES);
        
    }];
}

-(void)fetchAndCreateAlbumAndSave{
  if([self albumExist] == false)
     [self createAlbum];
    else
    [self saveNewVideoToCameraRoll:[NSURL fileURLWithPath:_tmpVideoPath] andCallBack:^(BOOL success,NSString*fpath) {
        if(success)
        {
           // compblock(YES);
        }
    }];
}

-(BOOL)albumExist{
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    options.predicate = [NSPredicate predicateWithFormat:@"title = %@",
                         @"hend"];
    PHFetchResult *fetch = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:options];
    
    return (BOOL)fetch.firstObject;
}

-(void)createAlbum{
    
    NSLog(@"createAlbum");
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //
        [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"hend"];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //
        if(success){
            
            //remaining
            [self setAssetCollection];
            [self saveNewVideoToCameraRoll:[NSURL fileURLWithPath:_tmpVideoPath] andCallBack:^(BOOL success,NSString*fpath) {
                if(success)
                {
                    //compblock(YES);
                }
            }];
            
            NSLog(@"jkhiuh");
        }
        else{
            
        }
    }];
    
}

-(void)setAssetCollection{
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    options.predicate = [NSPredicate predicateWithFormat:@"title = %@",
                         @"hend"];
    PHFetchResult *fetch = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:options];
    _assetCollection  = fetch.firstObject;

}

+(AVAsset*)getLastAsset{
   __block AVAsset *avAsse;
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",
                         PHAssetMediaTypeVideo];
   
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:options];
   // return fetchResult.firstObject;
    [[PHImageManager defaultManager] requestAVAssetForVideo:fetchResult.firstObject options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        // Use the AVAsset avAsset
        avAsse = avAsset;
        
    }];
    return avAsse;
}


-(void)deleteTmpFile{
    
    NSURL *url = [NSURL fileURLWithPath:self.tmpVideoPath];
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
