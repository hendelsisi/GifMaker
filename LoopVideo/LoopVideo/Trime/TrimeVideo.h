//
//  TrimeVideo.h
//  LoopVideo
//
//  Created by hend elsisi on 10/18/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface TrimeVideo : NSObject
//@property PHFetchResult * fetch;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) AVAsset *requestedAsset;
@property (strong, nonatomic) NSString *tmpVideoPath;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
typedef void(^myCompletion)(BOOL,NSString*);
+(AVAsset*)getLastAsset;
-(void)trimeVideo:(myCompletion)compblock ;
@property AVAsset *tempVideo;

@end
