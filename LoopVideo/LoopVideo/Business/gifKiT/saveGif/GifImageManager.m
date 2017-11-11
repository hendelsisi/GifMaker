//
//  GifImageManager.m
//  LoopVideo
//
//  Created by hend elsisi on 11/10/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "GifImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <Photos/Photos.h>
#import "JWGifDecoder.h"

@implementation GifImageManager

+(void)save:(NSData*)data{
  //  UIImage *image = [UIImage imageWithData:data];
    
    JWGifDecoder *decoder = [JWGifDecoder decoderWithData:data];
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:decoder.frameCount];
    for (int i = 0; i < decoder.frameCount; i++) {
        JWGifFrame *frame = [decoder frameAtIndex:i];
        [frames addObject:frame];
    }

    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"是否保存成功：%d",success);
        }];
    }
    else {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        }];
    }


}

@end
